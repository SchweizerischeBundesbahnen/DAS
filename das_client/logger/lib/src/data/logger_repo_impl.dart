import 'dart:io';
import 'package:fimber/fimber.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/local/logger_cache_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/logging_api/logger_service.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:logger/src/log_entry.dart';
import 'package:synchronized/synchronized.dart';

class LoggerRepoImpl implements LoggerRepo {
  static const _rolloverTimeMinutes = 1;

  LoggerRepoImpl({required this.cacheService, required this.remoteService});

  final LoggerCacheService cacheService;
  final LoggerService remoteService;

  final _senderLock = Lock();
  final _cacheLock = Lock();

  DateTime _nextRolloverTimeStamp = DateTime.now().add(const Duration(minutes: _rolloverTimeMinutes));

  @override
  Future<void> saveLog(LogEntry log) async {
    _cacheLock.synchronized(() async {
      await cacheService.writeLog(log.toDto());
      await _optionalRolloverToRemote();
    });
  }

  Future<void> _optionalRolloverToRemote() async {
    try {
      final cacheThresholdExceeded = await cacheService.isCacheThresholdExceeded();
      if (cacheThresholdExceeded || _isRolloverTimeReached()) {
        Fimber.d('Rolling over log file');
        await cacheService.completeCache();
        _nextRolloverTimeStamp = DateTime.now().add(const Duration(minutes: _rolloverTimeMinutes));

        final completedLogFiles = await cacheService.completedLogFiles;
        for (final file in completedLogFiles) {
          await _sendLogsToRemote(file);
        }
      }
    } catch (e) {
      Fimber.e('Optional rollover to remote failed', ex: e);
    }
  }

  Future<void> _sendLogsToRemote(File file) async {
    try {
      final logEntries = await cacheService.getLogEntriesFrom(file);
      await _sendLogsSync(logEntries);
      file.deleteSync();
    } catch (e) {
      Fimber.e("Sending logs from file '${file.path}' failed", ex: e);
    }
  }

  Future<void> _sendLogsSync(List<LogEntryDto> cachedCompleted) async {
    await _senderLock.synchronized(() async {
      try {
        await remoteService.sendLogs(cachedCompleted);
        Fimber.i('Successfully sent logs to backend');
      } catch (e, s) {
        Fimber.w('Failed to send logs to backend.', ex: e, stacktrace: s);
        rethrow;
      }
    });
  }

  bool _isRolloverTimeReached() => _nextRolloverTimeStamp.isBefore(DateTime.now());
}
