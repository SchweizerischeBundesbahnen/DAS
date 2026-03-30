import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:preload/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('PreloadZipProcessor');

// TODO: Change name
// TODO: Delete extracted zip
class PreloadZipProcessor {
  /// folder used to download preload zip in application support folder.
  static String extractedFolderPath = '$preloadFolderPath/extracted';

  /// folder used to download preload zip in application support folder.
  static String preloadFolderPath = 'preload';

  PreloadZipProcessor({required this.sferaLocalRepo});

  final SferaLocalRepo sferaLocalRepo;

  Future<S3FileSyncStatus> processZip(File zip) async {
    _log.info('Start extracting file ${zip.name}');
    try {
      final extractionFolder = await _extractedFolder();
      final folder = Directory(p.join(extractionFolder.path, zip.name));
      await ZipFile.extractToDirectory(zipFile: zip, destinationDir: folder, zipFileCharset: Charsets.UTF_8.name);
      _log.info('Extracted ${zip.name}');
      zip.delete();

      final entities = await folder.list(recursive: true, followLinks: false).whereType<File>().toList();
      _log.info('${zip.name} has ${entities.length} files');
      final chunks = entities.slices(500);

      var allSuccess = true;
      for (final files in chunks) {
        // TODO: IO operations are already in background. Maybe remove isolate?
        final elements = await _readFilesAndParseValidElementsInIsolate(files);
        _log.info('Parsed ${elements.length} elements from chunk');
        final success = await sferaLocalRepo.saveData(elements);
        if (!success) {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        _log.fine('Processed all files from ${zip.name}.');
        return .downloaded;
      } else {
        // TODO: should log corrupted when one file could not be processed
        _log.warning('Could not processed all files from ${zip.name}.');
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

  Future<Directory> _extractedFolder() async {
    final supportDir = await getApplicationSupportDirectory();
    final extractedDir = Directory(p.join(supportDir.path, extractedFolderPath));
    if (!await extractedDir.exists()) {
      await extractedDir.create(recursive: true);
    }
    return extractedDir;
  }
}

/// top level method to run CPU heavy parse work on background isolate
Future<Iterable<SferaXmlElementDto>> _readFilesAndParseValidElementsInIsolate(List<File> files) =>
    Isolate.run(() async {
      final contents = await _readAllFilesAsStrings(files);
      return contents.map((content) => SferaReplyParser.parse(content));
    });

Future<List<String>> _readAllFilesAsStrings(List<File> files) async {
  final result = <String>[];
  for (final file in files) {
    try {
      result.add(await file.readAsString(encoding: utf8));
      file.delete();
    } catch (_) {}
  }
  return result;
}

extension _FileExtension on File {
  String get name => path.split(Platform.pathSeparator).last;
}
