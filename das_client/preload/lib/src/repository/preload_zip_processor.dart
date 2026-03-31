import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:preload/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('PreloadZipProcessor');

/// batch of files processed at a time before saved to database.
const int _batchSize = 1000;

// TODO: Change name
class PreloadZipProcessor {
  /// folder used to download preload zip in application support folder.
  static String preloadFolderPath = 'preload';

  PreloadZipProcessor({required this.sferaLocalRepo});

  final SferaLocalRepo sferaLocalRepo;

  // Caller side
  Future<S3FileSyncStatus> processZip(File zip) async {
    _log.info('Start extracting file ${zip.name}');

    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(_zipWorker, _ZipWork(zip.path, receivePort.sendPort));

      var allSuccess = true;
      await for (final message in receivePort) {
        if (message == null) break;
        if (message is Map && message['error'] != null) {
          _log.severe('Failed to process files from zip ${zip.name}. Failed with error "${message['error']}"');
          allSuccess = false;
          continue;
        }
        final elements = message as List<SferaXmlElementDto>;
        final success = await sferaLocalRepo.saveData(elements);
        if (!success) {
          allSuccess = false;
        }
      }

      zip.delete();

      if (allSuccess) {
        _log.fine('Processed all files from ${zip.name}.');
        return .downloaded;
      } else {
        _log.severe('Could not processed all files from ${zip.name}.');
        return .corrupted;
      }
    } catch (e) {
      _log.fine('Extract failed with $e for file ${zip.name}.');
      return .error;
    }
  }

  Future<void> cleanup() async {
    final preloadDir = await preloadFolder();
    if (preloadDir.existsSync()) {
      preloadDir.delete(recursive: true);
    }
  }

  Future<Directory> preloadFolder() async {
    final supportDir = await getApplicationSupportDirectory();
    final preloadDir = Directory(p.join(supportDir.path, preloadFolderPath));
    if (!await preloadDir.exists()) {
      await preloadDir.create(recursive: true);
    }
    return preloadDir;
  }
}

class _ZipWork {
  _ZipWork(this.zipPath, this.sendPort);

  final String zipPath;
  final SendPort sendPort;

  void sendDone() => sendPort.send(null);
}

/// top level method to run CPU heavy work on background isolate
void _zipWorker(_ZipWork work) async {
  try {
    final input = InputFileStream(work.zipPath);
    final archive = ZipDecoder().decodeStream(input, verify: false);

    final batch = <SferaXmlElementDto>[];
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final content = utf8.decode(file.content);
      batch.add(SferaReplyParser.parse(content));

      if (batch.length >= _batchSize) {
        work.sendPort.send(batch);
        batch.clear();
      }
    }
    if (batch.isNotEmpty) work.sendPort.send(batch);
    work.sendDone();
  } catch (e) {
    work.sendPort.send({'error': e.toString()});
    work.sendDone();
  }
}

extension _FileExtension on File {
  String get name => path.split(Platform.pathSeparator).last;
}
