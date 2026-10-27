import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:connectivity_x/component.dart';
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

class PreloadRepositoryImpl({
  required final PreloadZipProcessor preloadZipProcessor,
  required final PreloadLocalDatabaseService databaseService,
  required final ConnectivityManager connectivityManager,
  required final SferaLocalRepo sferaLocalRepo,

  /// added only for development purposes
  required final bool disablePreload,
}) implements PreloadRepository {
  static const syncInterval = Duration(minutes: 5);
  static const resumePreloadDelay = Duration(minutes: 2);
  static const segmentPrefix = 'Segment';

  this {
    _init();
  }

  S3Client? _s3client;
  StreamSubscription? _databaseSubscription;
  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;
  Timer? _resumeTimer;

  Future<void>? _currentRun;
  PreloadStatus _currentStatus = .idle;
  bool _isRoamingWithoutWifi = false;
  final _rxDetails = BehaviorSubject<PreloadDetails>();

  @override
  Stream<PreloadDetails> get preloadDetails => _rxDetails.stream;

  void _init() {
    _log.info('Initializing PreloadRepositoryImpl...');
    _databaseSubscription = databaseService.watchAll().listen((files) => _emit(files));
    _connectivitySubscription = Rx.combineLatest2<bool, bool, bool>(
      connectivityManager.isNetworkRoaming,
      connectivityManager.isWifiActive,
      (isNetworkRoaming, isWifiActive) => isNetworkRoaming && !isWifiActive,
    ).listen(_onRoamingWithoutWifiChanged);
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
  void triggerPreload() {
    if (disablePreload) {
      _log.fine('Preload has been disabled by development flag. Cancelling...');
      return;
    }

    if (_s3client == null) {
      _log.warning('S3 client is not initialized. Cannot perform preload.');
      _currentStatus = .missingConfiguration;
      return;
    }

    if (_isRoamingWithoutWifi) {
      _log.info('Roaming without Wi-Fi detected. Skipping new preload request.');
      return;
    }

    if (_currentStatus == .running) {
      _log.info('Preload is already running. Skipping new preload request.');
      return;
    }

    _currentRun = _runPreload().whenComplete(() {
      _currentRun = null;
      _emit();
    });
    _emit();
  }

  @override
  Future<void> stopPreload() async {
    final currentRun = _currentRun;
    if (currentRun == null) return;

    try {
      _log.info('Stopping preload...');
      _currentStatus = .stopping;
      _s3client?.cancelDownloads();
      preloadZipProcessor.stop();
      await currentRun;
    } catch (e, s) {
      _log.severe('Error while stopping preload.', e, s);
    } finally {
      _currentStatus = .idle;
      _emit();
    }
  }

  S3Client createS3Client(AwsConfiguration awsConfiguration) => S3Client(configuration: awsConfiguration);

  @override
  void dispose() {
    stopPreload();
    _databaseSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _rxDetails.close();
    _disablePreload();
  }

  Future<void> _runPreload() async {
    _log.info('Starting preload...');
    _currentStatus = .running;
    try {
      await _cleanup();
      await _listS3BucketAndUpdateLocalDatabase();
      await _processAllFiles();
    } catch (e, s) {
      _log.severe('Error during preload.', e, s);
    } finally {
      _log.info(_currentStatus == .stopping ? 'Preload stopped.' : 'Preload completed.');
      _currentStatus = .idle;
    }
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
    final prioritizedFiles = [
      ...filesToProcess.where((file) => file.name.startsWith(segmentPrefix)),
      ...filesToProcess.where((file) => !file.name.startsWith(segmentPrefix)),
    ];
    _log.info(
      'Processing files from local database (initial: ${filesToProcess.whereStatus(.initial).length}, '
      'error: ${filesToProcess.whereStatus(.error).length}, '
      'corrupted: ${filesToProcess.whereStatus(.corrupted).length}, '
      'downloaded: ${filesToProcess.whereStatus(.downloaded).length}).',
    );

    final processingFutures = <Future>[];
    try {
      final preloadDirectory = await preloadZipProcessor.preloadDirectory();
      for (final file in prioritizedFiles) {
        if (_currentStatus == .stopping) break;
        if (file.status == .initial || file.status == .error) {
          _log.info('Processing file ${file.name} with status ${file.status.name}.');
          try {
            final downloaded = await _s3client!.downloadFile(file.name, saveTo: preloadDirectory);
            await Future.wait(processingFutures);
            if (_currentStatus == .stopping) break;
            processingFutures.add(_processZip(_ZipToProcess(file: file, zip: downloaded)));
          } catch (e, s) {
            if (_currentStatus == .stopping) break; // download aborted by stop, keep status to retry later
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

  Future<void> _emit([List<S3File>? files]) async {
    if (_rxDetails.isClosed) return;
    final details = await _gatherDetails(files);
    _rxDetails.add(details);
  }

  Future<PreloadDetails> _gatherDetails(List<S3File>? files) async {
    files = files ?? await databaseService.findAll();
    return PreloadDetails(files: files, status: _currentStatus, metrics: await sferaLocalRepo.getMetrics());
  }

  void _setTriggerForPeriodicPreload() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => triggerPreload());
  }

  void _disablePreload() {
    _s3client = null;
    _syncTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _onRoamingWithoutWifiChanged(bool isRoamingWithoutWifi) {
    if (_isRoamingWithoutWifi == isRoamingWithoutWifi) return;
    _isRoamingWithoutWifi = isRoamingWithoutWifi;

    if (isRoamingWithoutWifi) {
      _resumeTimer?.cancel();
      _log.info('Roaming without Wi-Fi detected. Stopping preload...');
      stopPreload();
      return;
    }

    _log.info('Connectivity back to normal. Scheduling preload restart in ${resumePreloadDelay.inMinutes} minutes.');
    _resumeTimer?.cancel();
    _resumeTimer = Timer(resumePreloadDelay, () {
      _log.info('Restart preload delay elapsed. Triggering preload...');
      triggerPreload();
    });
  }

  void _logConfigurationIsUpdated(AwsConfiguration awsConfiguration) {
    _log.info(
      'Received non empty AWS config update: bucketUrl=${awsConfiguration.bucketUrl}, '
      'accessKey=${awsConfiguration.accessKey.codeUnits.map((e) => '*').join()}, '
      'accessSecret=${awsConfiguration.accessSecret.codeUnits.map((e) => '*').join()}',
    );
  }
}

class _ZipToProcess({required final S3File file, required final File zip});
