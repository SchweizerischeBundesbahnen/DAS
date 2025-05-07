import 'package:clock/clock.dart';
import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/local/log_file_service.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:logger/src/log_entry.dart';
import 'package:synchronized/synchronized.dart';

class LoggerRepoImpl implements LoggerRepo {
  static const _rolloverTimeMinutes = 1;

  LoggerRepoImpl({required this.fileService, required this.apiService});

  final LogFileService fileService;
  final LogApiService apiService;

  final _senderLock = Lock();
  final _cacheLock = Lock();

  DateTime _nextRolloverTimeStamp = clock.now().add(const Duration(minutes: _rolloverTimeMinutes));

  @override
  Future<void> saveLog(LogEntry log) async {
    return _cacheLock.synchronized(() async {
      await fileService.writeLog(log.toDto());
      await _optionalRolloverToRemote();
    });
  }

  Future<void> _optionalRolloverToRemote() async {
    try {
      final cacheHasFullLogFiles = await fileService.hasCompletedLogFiles;
      final rolloverReached = _isRolloverTimeReached();
      if (cacheHasFullLogFiles || rolloverReached) {
        Fimber.d('Rolling over log file');
        await fileService.completeCurrentFile();
        _nextRolloverTimeStamp = clock.now().add(const Duration(minutes: _rolloverTimeMinutes));

        await _processCompletedLogFiles();
      }
    } catch (e) {
      Fimber.e('Optional rollover to remote failed', ex: e);
    }
  }

  Future<void> _processCompletedLogFiles() async {
    final completedLogFiles = await fileService.completedLogFiles;
    Fimber.i('Found completedLogFiles: ${completedLogFiles.length}');
    for (final file in completedLogFiles) {
      try {
        await _sendLogsSync(file.logEntries);
        await fileService.deleteLogFile(file);
      } catch (e) {
        if (e is HttpException) {
          Fimber.e('Connection error while sending logs to remote. Try again in next rollover.', ex: e);
          break;
        } else {
          Fimber.e('Send and clear logs from ${file.file.path} failed.', ex: e);
        }
      }
    }
  }

  Future<void> _sendLogsSync(Iterable<LogEntryDto> logs) async {
    await _senderLock.synchronized(() async {
      await apiService.sendLogs(logs);
      Fimber.d('Successfully sent logs to backend');
    });
  }

  bool _isRolloverTimeReached() => _nextRolloverTimeStamp.isBefore(clock.now());
}
