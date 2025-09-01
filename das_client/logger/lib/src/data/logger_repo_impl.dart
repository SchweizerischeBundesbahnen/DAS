import 'dart:io';

import 'package:clock/clock.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:logger/src/log_entry.dart';
import 'package:logging/logging.dart';
import 'package:synchronized/synchronized.dart';

final _log = Logger('LoggerRepoImpl');

class LoggerRepoImpl implements LoggerRepo {
  static const _rolloverTimeMinutes = 5;
  static const _retryDelayAfterFailedSendMinutes = 1;

  LoggerRepoImpl({required this.fileService, required this.apiService});

  final LogFileService fileService;
  final LogApiService apiService;

  final _senderLock = Lock();
  final _cacheLock = Lock();

  DateTime _nextRolloverTimeStamp = clock.now().add(const Duration(minutes: _rolloverTimeMinutes));
  DateTime _stopSendingUntil = clock.now().subtract(const Duration(milliseconds: 10));

  @override
  Future<void> saveLog(LogEntry log) async {
    return _cacheLock.synchronized(() async {
      await fileService.writeLog(log.toDto());
      await _optionalRolloverToRemote();
    });
  }

  Future<void> _optionalRolloverToRemote() async {
    try {
      if (await _shouldRollover()) {
        _log.fine('Rolling over log file');
        await fileService.completeCurrentFile();
        _nextRolloverTimeStamp = clock.now().add(const Duration(minutes: _rolloverTimeMinutes));

        await _rolloverAllLogs();
      }
    } catch (e) {
      _log.severe('Optional rollover to remote failed', e);
    }
  }

  Future<void> _rolloverAllLogs() async {
    final completedLogFiles = await fileService.completedLogFiles;
    _log.fine('Found completedLogFiles: ${completedLogFiles.length}');
    for (final file in completedLogFiles) {
      try {
        await _sendLogsSync(file);
      } catch (ex) {
        _log.severe('Connection error while sending logs to remote.', ex);
        _stopSendingUntil = clock.now().add(Duration(minutes: _retryDelayAfterFailedSendMinutes));
        break;
      }
      await _tryDelete(file);
    }
  }

  Future<void> _tryDelete(File file) async {
    try {
      await fileService.deleteLogFile(file);
    } catch (ex) {
      _log.severe('Send and clear logs from ${file.path} failed.', ex);
    }
  }

  Future<void> _sendLogsSync(File logFile) async {
    await _senderLock.synchronized(() async {
      _log.fine('Sending logs from file: ${logFile.path}');
      await apiService.sendLogs(logFile);
      _log.fine('Successfully sent logs to splunk');
    });
  }

  Future<bool> _shouldRollover() async {
    final hasLogFilesToSend = await fileService.hasCompletedLogFiles;
    final isRolloverTimeReached = _isRolloverTimeReached();
    final isAllowedToSend = _stopSendingUntil.isBefore(clock.now());
    return isAllowedToSend && (hasLogFilesToSend || isRolloverTimeReached);
  }

  bool _isRolloverTimeReached() => _nextRolloverTimeStamp.isBefore(clock.now());
}
