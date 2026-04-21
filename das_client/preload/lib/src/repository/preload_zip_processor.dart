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

/// Batch of files processed at a time before saved to database.
const int _batchSize = 200;

/// Decodes and processes preloaded ZIPs and saves the content to the local SFERA database.
/// Uses background isolates with batch database inserts to prevent UI freezes.
class PreloadZipProcessor {
  PreloadZipProcessor({required this.sferaLocalRepo});

  final SferaLocalRepo sferaLocalRepo;

  final Set<String> _processedFiles = {};

  Future<S3FileSyncStatus> extractToLocalDatabase(File zip) async {
    _log.info('Start extracting file ${zip.name}');

    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(
        _zipWorker,
        _ZipWork(zip.path, receivePort.sendPort, _processedFiles.toList(growable: false)),
      );

      var allSuccess = true;
      await for (final message in receivePort) {
        if (message == null || message is! Map) break;

        if (message[_errorAttribute] != null) {
          _log.severe('Failed to process files from zip ${zip.name}. Failed with error "${message['error']}"');
          allSuccess = false;
          continue;
        }

        if (message[_batchAttribute] != null) {
          final elements = message[_batchAttribute] as List<SferaXmlElementDto>;

          final success = await sferaLocalRepo.saveData(elements);
          if (success) {
            final files = message[_processedFilesAttribute] as List<String>;
            _processedFiles.addAll(files);
          } else {
            allSuccess = false;
          }
        }
      }

      receivePort.close();
      _saveDelete(zip);

      if (allSuccess) {
        _log.fine('Processed all files from ${zip.name}.');
        return .downloaded;
      } else {
        _log.severe('Could not processed all files from ${zip.name}.');
        return .corrupted;
      }
    } catch (e) {
      _log.severe('Extract failed for file ${zip.name}.', e);
      return .error;
    }
  }

  Future<void> cleanup() async {
    _processedFiles.clear();
    try {
      final preloadDir = await preloadDirectory();
      if (preloadDir.existsSync()) {
        preloadDir.delete(recursive: true);
      }
    } catch (e) {
      _log.severe('Failed to delete preload directory for clean-up.', e);
    }
  }

  Future<Directory> preloadDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final preloadDir = Directory(p.join(supportDir.path, 'preload'));
    if (!await preloadDir.exists()) {
      await preloadDir.create(recursive: true);
    }
    return preloadDir;
  }

  Future<void> _saveDelete(File zip) async {
    try {
      if (zip.existsSync()) {
        await zip.delete();
      }
    } catch (e) {
      _log.severe('Failed to delete file ${zip.name}.', e);
    }
  }
}

const String _errorAttribute = 'error';
const String _processedFilesAttribute = 'processedFiles';
const String _batchAttribute = 'batch';

class _ZipWork {
  _ZipWork(this.zipPath, this.sendPort, this.previouslyProcessed);

  final String zipPath;
  final SendPort sendPort;
  final List<String> previouslyProcessed;

  void sendDone() => sendPort.send(null);
}

/// Top level method to run CPU heavy work on background isolate
void _zipWorker(_ZipWork work) async {
  sendResult(List<SferaXmlElementDto> batch, List<String> processedFiles) {
    work.sendPort.send({
      _batchAttribute: batch,
      _processedFilesAttribute: processedFiles,
    });
  }

  try {
    final input = InputFileStream(work.zipPath);
    final archive = ZipDecoder().decodeStream(input, verify: false);

    final batchFiles = <String>[];
    final batch = <SferaXmlElementDto>[];
    for (final file in archive.files) {
      if (!file.isFile) continue;

      final fileName = file.name;
      if (work.previouslyProcessed.contains(fileName)) continue;

      final content = utf8.decode(file.content);
      batch.add(SferaReplyParser.parse(content));
      batchFiles.add(fileName);

      if (batch.length >= _batchSize) {
        sendResult(batch, batchFiles);
        batch.clear();
      }
    }
    if (batch.isNotEmpty) sendResult(batch, batchFiles);
    work.sendDone();
  } catch (e) {
    work.sendPort.send({_errorAttribute: e.toString()});
    work.sendDone();
  }
}

extension _FileExtension on File {
  String get name => path.split(Platform.pathSeparator).last;
}
