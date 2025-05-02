import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:path_provider/path_provider.dart';

class LoggerCacheService {
  /// TODO: currently set below 8kb. See: https://github.com/SchweizerischeBundesbahnen/DAS/issues/850
  static const _maxFileSize = 7 * 1024;
  static const _prefix = 'das-log';
  static const _lastSavedFileName = '$_prefix-lastSavedFile.json';

  Future<void> writeLog(LogEntryDto log) async {
    final currentCacheFile = await _currentCacheFile;
    currentCacheFile.writeAsStringSync('${log.toJsonString()},', mode: FileMode.append);
  }

  Future<void> completeCache() async {
    final logPath = await _getLogPath();
    final currentCacheFile = await _currentCacheFile;
    currentCacheFile.renameSync('$logPath/$_prefix-${DateTime.now().millisecondsSinceEpoch}.json');
  }

  Future<List<LogEntryDto>> getLogEntriesFrom(File logFile) async {
    Fimber.d('Get logs from ${logFile.path}');

    var content = logFile.readAsStringSync();
    content = '[${content.substring(0, content.length - 1)}]'; // Remove trailing comma

    final Iterable decodedLogs = json.decode(content);
    return List<LogEntryDto>.from(decodedLogs.map((json) => LogEntryDto.fromJson(json)));
  }

  Future<bool> isCacheThresholdExceeded() async {
    final currentCacheFile = await _currentCacheFile;
    return currentCacheFile.lengthSync() > _maxFileSize;
  }

  Future<String> _getLogPath() async {
    return '${(await getApplicationSupportDirectory()).path}/logs';
  }

  Future<File> get _currentCacheFile async {
    final logPath = await _getLogPath();
    final result = File('$logPath/$_lastSavedFileName');
    if (!(result.existsSync())) {
      result.createSync(recursive: true);
    }
    return result;
  }

  Future<Iterable<File>> get completedLogFiles async {
    final logPath = await _getLogPath();
    final logFiles = Directory(logPath).listSync();
    return logFiles.where((file) => _isCompletedLogFile(file)).cast<File>();
  }

  bool _isCompletedLogFile(FileSystemEntity file) =>
      file is File && file.path.endsWith('.json') && !file.path.contains(_lastSavedFileName);
}
