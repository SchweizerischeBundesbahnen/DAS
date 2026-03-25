import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/model/preload_details.dart';
import 'package:preload/src/model/s3_file.dart';
import 'package:preload/src/repository/preload_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('PreloadRepositoryImpl');

class PreloadRepositoryImpl implements PreloadRepository {
  static const syncInterval = Duration(minutes: 5);

  PreloadRepositoryImpl({
    required this.databaseService,
    required this.sferaLocalRepo,
    required this.disablePreload,
  }) {
    _init();
  }

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
  void updateConfiguration(AwsConfiguration awsConfiguration) {
    _log.info(
      'Preload configuration updated: bucketUrl=${awsConfiguration.bucketUrl}, '
      'accessKey=${awsConfiguration.accessKey.codeUnits.map((e) => '*').join()}, '
      'accessSecret=${awsConfiguration.accessSecret.codeUnits.map((e) => '*').join()}',
    );

    _s3client = createS3Client(awsConfiguration);
    triggerPreload();

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => triggerPreload());
  }

  S3Client createS3Client(AwsConfiguration awsConfiguration) {
    return S3Client(configuration: awsConfiguration);
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

  Future<int> _cleanup() => sferaLocalRepo.cleanup();

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

    for (final file in filesToProcess) {
      if (file.status == .initial || file.status == .error) {
        _log.info('Processing file ${file.name} with status ${file.status.name}.');
        await _downloadExtractAndSaveS3FileContent(file);
      } else {
        _log.finer('Skipping file ${file.name} with status ${file.status}.');
      }
    }
  }

  Future<void> _downloadExtractAndSaveS3FileContent(S3File file) async {
    try {
      final fileData = await _s3client!.getObject(file.name);
      if (fileData == null) {
        _log.warning('Failed to download file ${file.name}.');
        await databaseService.saveS3File(file.copyWith(status: .error));
        return;
      }

      _log.info('File ${file.name} downloaded successfully. Size: ${fileData.length} bytes.');

      final ttd = TransferableTypedData.fromList([Uint8List.fromList(fileData)]);
      final contents = await _unzipAndDecodeInIsolate(ttd);

      final success = await sferaLocalRepo.saveData(contents);
      if (success) {
        _log.info('All data extracted from file ${file.name} saved successfully.');
        await databaseService.saveS3File(file.copyWith(status: .downloaded));
      } else {
        _log.warning('Failed to save some data extracted from file ${file.name}. Marking as corrupted.');
        await databaseService.saveS3File(file.copyWith(status: .corrupted));
      }
    } catch (e, s) {
      _log.severe('Error downloading file ${file.name}.', e, s);
      await databaseService.saveS3File(file.copyWith(status: .error));
    }
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

  @override
  void dispose() {
    _databaseSubscription?.cancel();
    _rxDetails.close();
    _syncTimer?.cancel();
  }
}

/// top level method to run CPU heavy zip decode work on background isolate
Future<List<String>> _unzipAndDecodeInIsolate(TransferableTypedData ttd) => Isolate.run(() {
  final bytes = ttd.materialize().asUint8List();
  final archive = ZipDecoder().decodeBytes(bytes);
  final contents = <String>[];
  for (final f in archive.files) {
    if (!f.isFile) continue;
    contents.add(utf8.decode(f.content as List<int>));
  }
  return contents;
});
