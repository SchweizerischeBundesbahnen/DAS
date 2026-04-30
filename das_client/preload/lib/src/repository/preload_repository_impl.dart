import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/model/preload_details.dart';
import 'package:preload/src/model/s3_file.dart';
import 'package:preload/src/repository/preload_repository.dart';
import 'package:preload/src/repository/preload_zip_processor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('PreloadRepositoryImpl');

class PreloadRepositoryImpl implements PreloadRepository {
  static const syncInterval = Duration(minutes: 5);

  PreloadRepositoryImpl({
    required this.preloadZipProcessor,
    required this.databaseService,
    required this.sferaLocalRepo,
    required this.disablePreload,
  }) {
    _init();
  }

  final PreloadZipProcessor preloadZipProcessor;
  final PreloadLocalDatabaseService databaseService;
  final SferaLocalRepo sferaLocalRepo;

  /// added only for development purposes
  final bool disablePreload;

  S3Client? _s3client;
  StreamSubscription? _databaseSubscription;
  Timer? _syncTimer;

  bool _isRunning = false;
  final _rxDetails = BehaviorSubject<PreloadDetails>();

  @override
  Stream<PreloadDetails> get preloadDetails => _rxDetails.stream;

  void _init() {
    _log.info('Initializing PreloadRepositoryImpl...');
    _databaseSubscription = databaseService.watchAll().listen((files) => _emit(files));
  }

  @override
  void updateConfiguration(AwsConfiguration? awsConfiguration) {
    if (awsConfiguration == null) {
      _log.info('Received empty AWS config - disabling preload.');
      _disablePreload();
      return;
    }
    _logConfigurationIsUpdated(awsConfiguration);

    _s3client = createS3Client(awsConfiguration);

    triggerPreload();

    _setTriggerForPeriodicPreload();
  }

  @override
  void triggerPreload() async {
    if (disablePreload) {
      _log.fine('Preload has been disabled by development flag. Cancelling...');
      return;
    }

    if (_s3client == null) {
      _log.warning('S3 client is not initialized. Cannot perform preload.');
      return;
    }

    if (_isRunning) {
      _log.info('Preload is already running. Skipping new preload request.');
      return;
    }
    _updateRunning(true);
    _log.info('Starting preload...');

    try {
      await _cleanup();
      await _listS3BucketAndUpdateLocalDatabase();
      await _processAllFiles();
    } catch (e, s) {
      _log.severe('Error during preload.', e, s);
    }

    _log.info('Preload completed.');
    _updateRunning(false);
  }

  S3Client createS3Client(AwsConfiguration awsConfiguration) => S3Client(configuration: awsConfiguration);

  @override
  void dispose() {
    _databaseSubscription?.cancel();
    _rxDetails.close();
    _disablePreload();
  }

  Future<void> _cleanup() async {
    await sferaLocalRepo.cleanup();
    await preloadZipProcessor.cleanup();
  }

  Future<void> _listS3BucketAndUpdateLocalDatabase() async {
    final result = await _s3client!.listBucket();
    if (result == null) {
      _log.warning('Failed to retrieve bucket contents.');
      return;
    }

    _log.info('Bucket contents retrieved successfully. Total items: ${result.contents.length}');

    final dbEntries = await databaseService.findAll();

    int newItem = 0;
    int updatedItem = 0;

    for (final s3Content in result.contents) {
      final matchingDbEntry = dbEntries.firstWhereOrNull((it) => it.name == s3Content.key);
      if (matchingDbEntry == null) {
        _log.fine('No database entry for key ${s3Content.key}. Adding new entry.');
        await databaseService.saveS3File(
          S3File(name: s3Content.key, eTag: s3Content.eTag, size: s3Content.size, status: .initial),
        );
        newItem++;
      } else {
        if (matchingDbEntry.eTag != s3Content.eTag) {
          _log.fine('File ${s3Content.key} has changed. Updating database entry.');
          await databaseService.saveS3File(
            matchingDbEntry.copyWith(eTag: s3Content.eTag, size: s3Content.size, status: .initial),
          );
          updatedItem++;
        } else {
          _log.finer('Database entry already exists for key ${s3Content.key}.');
        }
        dbEntries.remove(matchingDbEntry);
      }
    }

    for (final deletedEntry in dbEntries) {
      await databaseService.deleteS3File(deletedEntry);
    }

    _log.info(
      'List bucket completed. New items: $newItem, Updated items: $updatedItem, Deleted items: ${dbEntries.length}',
    );
  }

  Future<void> _processAllFiles() async {
    final filesToProcess = await databaseService.findAll();
    _log.info(
      'Processing files from local database (initial: ${filesToProcess.whereStatus(.initial).length}, '
      'error: ${filesToProcess.whereStatus(.error).length}, '
      'corrupted: ${filesToProcess.whereStatus(.corrupted).length}, '
      'downloaded: ${filesToProcess.whereStatus(.downloaded).length}).',
    );

    final processingFutures = <Future>[];
    try {
      final preloadDirectory = await preloadZipProcessor.preloadDirectory();
      for (final file in filesToProcess) {
        if (file.status == .initial || file.status == .error) {
          _log.info('Processing file ${file.name} with status ${file.status.name}.');
          try {
            final downloaded = await _s3client!.downloadFile(file.name, saveTo: preloadDirectory);
            await Future.wait(processingFutures);
            processingFutures.add(_processZip(_ZipToProcess(file: file, zip: downloaded)));
          } catch (e, s) {
            _log.severe('Error downloading file ${file.name}.', e, s);
            await databaseService.saveS3File(file.copyWith(status: .error));
          }
        } else {
          _log.finer('Skipping file ${file.name} with status ${file.status}.');
        }
      }
    } finally {
      await Future.wait(processingFutures);
    }
  }

  Future<void> _processZip(_ZipToProcess toProcess) async {
    final result = await preloadZipProcessor.extractToLocalDatabase(toProcess.zip);
    await databaseService.saveS3File(toProcess.file.copyWith(status: result));
  }

  void _updateRunning(bool isRunning) {
    _isRunning = isRunning;
    _emit();
  }

  Future<void> _emit([List<S3File>? files]) async {
    final details = await _gatherDetails(files);
    _rxDetails.add(details);
  }

  PreloadStatus _status() {
    if (_s3client == null) return .missingConfiguration;
    return _isRunning ? .running : .idle;
  }

  Future<PreloadDetails> _gatherDetails(List<S3File>? files) async {
    files = files ?? await databaseService.findAll();
    return PreloadDetails(files: files, status: _status(), metrics: await sferaLocalRepo.getMetrics());
  }

  void _setTriggerForPeriodicPreload() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => triggerPreload());
  }

  void _disablePreload() {
    _s3client = null;
    _syncTimer?.cancel();
  }

  void _logConfigurationIsUpdated(AwsConfiguration awsConfiguration) {
    _log.info(
      'Received non empty AWS config update: bucketUrl=${awsConfiguration.bucketUrl}, '
      'accessKey=${awsConfiguration.accessKey.codeUnits.map((e) => '*').join()}, '
      'accessSecret=${awsConfiguration.accessSecret.codeUnits.map((e) => '*').join()}',
    );
  }
}

class _ZipToProcess {
  _ZipToProcess({required this.file, required this.zip});

  final S3File file;
  final File zip;
}
