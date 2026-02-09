import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/model/s3file.dart';
import 'package:preload/src/repository/preload_repository.dart';
import 'package:settings/component.dart';

final _log = Logger('PreloadRepositoryImpl');

class PreloadRepositoryImpl implements PreloadRepository {
  PreloadRepositoryImpl({required this.databaseService});

  final PreloadLocalDatabaseService databaseService;
  S3Client? _s3client;
  bool _isRunning = false;

  @override
  void updateConfiguration(AwsConfiguration awsConfiguration) {
    _log.info(
      'Preload configuration updated: bucketUrl=${awsConfiguration.bucketUrl}, '
      'accessKey=${awsConfiguration.accessKey.codeUnits.map((e) => '*').join()}, '
      'accessSecret=${awsConfiguration.accessSecret.codeUnits.map((e) => '*').join()}',
    );

    _s3client = S3Client(configuration: awsConfiguration);
    doPreload();
  }

  void doPreload() async {
    if (_s3client == null) {
      _log.warning('S3 client is not initialized. Cannot perform preload.');
      return;
    }

    if (_isRunning) {
      _log.info('Preload is already running. Skipping new preload request.');
      return;
    }
    _isRunning = true;
    _log.info('Starting preload...');

    try {
      await _listS3BucketAndUpdateLocalDatabase();
      await _processAllFiles();
    } catch (e, s) {
      _log.severe('Error during preload.', e, s);
    }

    _isRunning = false;
  }

  Future<void> _listS3BucketAndUpdateLocalDatabase() async {
    final result = await _s3client!.listBucket();
    if (result != null) {
      _log.info('Bucket contents retrieved successfully. Total items: ${result.contents.length}');

      final dbEntries = await databaseService.findAllNotDeletedFiles();

      int newItem = 0;
      int updatedItem = 0;

      for (final s3Content in result.contents) {
        final matchingDbEntry = dbEntries.firstWhereOrNull((it) => it.name == s3Content.key);
        if (matchingDbEntry == null) {
          _log.fine('No database entry for key ${s3Content.key}. Adding new entry.');
          await databaseService.saveS3File(
            S3File(name: s3Content.key, eTag: s3Content.eTag, size: s3Content.size, status: S3FileSyncStatus.initial),
          );
          newItem++;
        } else {
          if (matchingDbEntry.eTag != s3Content.eTag) {
            _log.fine('File ${s3Content.key} has changed. Updating database entry.');
            await databaseService.saveS3File(
              matchingDbEntry.copyWith(eTag: s3Content.eTag, size: s3Content.size, status: S3FileSyncStatus.initial),
            );
            updatedItem++;
          } else {
            _log.finer('Database entry already exists for key ${s3Content.key}.');
          }
          dbEntries.remove(matchingDbEntry);
        }
      }

      for (final deletedEntry in dbEntries) {
        await databaseService.saveS3File(deletedEntry.copyWith(status: S3FileSyncStatus.deleted));
      }

      _log.info(
        'List bucket completed. New items: $newItem, Updated items: $updatedItem, Deleted items: ${dbEntries.length}',
      );
    } else {
      _log.warning('Failed to retrieve bucket contents.');
    }
  }

  Future<void> _processAllFiles() async {
    final filesToProcess = await databaseService.findAllNotDeletedFiles();
    _log.info(
      'Processing files from local database (initial: ${filesToProcess.where((f) => f.status == S3FileSyncStatus.initial).length}, '
      'error: ${filesToProcess.where((f) => f.status == S3FileSyncStatus.error).length}, '
      'downloaded: ${filesToProcess.where((f) => f.status == S3FileSyncStatus.downloaded).length}).',
    );

    for (final file in filesToProcess) {
      if (file.status == S3FileSyncStatus.initial || file.status == S3FileSyncStatus.error) {
        _log.info('Processing file ${file.name} with status ${file.status.name}.');
        await _downloadAndProcessS3File(file);
      } else {
        _log.finer('Skipping file ${file.name} with status ${file.status}.');
      }
    }
  }

  Future<void> _downloadAndProcessS3File(S3File file) async {
    try {
      final fileData = await _s3client!.getObject(file.name);
      if (fileData != null) {
        _log.info('File ${file.name} downloaded successfully. Size: ${fileData.length} bytes.');

        final archive = ZipDecoder().decodeBytes(fileData);
        for (final archiveFile in archive.files) {
          if (archiveFile.isFile) {
            final content = utf8.decode(archiveFile.readBytes()!);
            _log.finer(
              'Extracted file ${archiveFile.name} from archive ${file.name}. Content length: ${content.length} characters. ${content.substring(0, content.length > 100 ? 100 : content.length)}',
            );
            // TODO: Process the content of the extracted file as needed.
          }
        }

        await databaseService.saveS3File(file.copyWith(status: S3FileSyncStatus.downloaded));
      } else {
        _log.warning('Failed to download file ${file.name}.');
        await databaseService.saveS3File(file.copyWith(status: S3FileSyncStatus.error));
      }
    } catch (e, s) {
      _log.severe('Error downloading file ${file.name}.', e, s);
      await databaseService.saveS3File(file.copyWith(status: S3FileSyncStatus.error));
    }
  }
}
