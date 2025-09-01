import 'dart:convert';
import 'dart:io';

import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LogFileServiceImpl implements LogFileService {
  /// TODO: currently set below 8kb. See: https://github.com/SchweizerischeBundesbahnen/DAS/issues/850
  static const _maxFileSize = 7 * 1024;
  static const _filePrefix = 'das-log';
  static const _lastSavedFileName = '$_filePrefix-lastSavedFile.json';

  @override
  Future<bool> get hasCompletedLogFiles async => (await completedLogFiles).isNotEmpty;

  @override
  Future<void> writeLog(LogEntryDto log) async {
    if (await _isLogTooLargeForCurrentFile(log)) {
      await completeCurrentFile();
    }
    await _appendToCurrentFile(log);
  }

  @override
  Future<Iterable<File>> get completedLogFiles async {
    final logDir = await _logDir;
    final logFiles = logDir.listSync();

    return logFiles.where((file) => _isCompletedLogFile(file)).cast<File>();
  }

  @override
  Future<void> deleteLogFile(File file) => file.delete();

  @override
  Future<void> completeCurrentFile() async {
    final currentCacheFile = await _currentCacheFile;
    currentCacheFile.renameSync(await _logFilePathWithTimestamp());
  }

  Future<String> _logFilePathWithTimestamp() async {
    final logDir = await _logDir;
    return p.join(logDir.path, '$_filePrefix-${DateTime.now().millisecondsSinceEpoch}.json');
  }

  Future<Directory> get _logDir async {
    final appSupportDirectory = (await getApplicationSupportDirectory());
    final result = Directory(p.join(appSupportDirectory.path, 'logs'));
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  Future<File> get _currentCacheFile async {
    final logDir = await _logDir;
    final result = File(p.join(logDir.path, _lastSavedFileName));

    if (!(result.existsSync())) result.createSync(recursive: true);

    return result;
  }

  Future<List<LogEntryDto>> _getLogEntriesFrom(File logFile) async {
    var content = logFile.readAsStringSync();
    content = '[${content.substring(0, content.length - 1)}]'; // Remove trailing comma

    final Iterable decodedLogs = json.decode(content);
    return List<LogEntryDto>.from(decodedLogs.map((json) => LogEntryDto.fromJson(json)));
  }

  bool _isCompletedLogFile(FileSystemEntity file) =>
      file is File && file.path.endsWith('.json') && !file.path.contains(_lastSavedFileName);

  Future<bool> _isLogTooLargeForCurrentFile(LogEntryDto log) async {
    final logAsJsonStringWithComma = '${log.toJsonString()},';
    final sizeToAdd = utf8.encode(logAsJsonStringWithComma).lengthInBytes;
    final currentFile = await _currentCacheFile;
    final currentFileSize = await currentFile.length();

    return (sizeToAdd + currentFileSize) >= _maxFileSize;
  }

  Future<void> _appendToCurrentFile(LogEntryDto log) async {
    var logString = log.toJsonString();
    final newCacheFile = await _currentCacheFile;
    if (await newCacheFile.length() > 0) {
      logString = ',$logString';
    }
    newCacheFile.writeAsStringSync(logString, mode: FileMode.append);
  }
}
