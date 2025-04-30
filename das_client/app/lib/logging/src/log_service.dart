import 'dart:convert';
import 'dart:io';

import 'package:app/di.dart';
import 'package:app/logging/src/log_entry.dart';
import 'package:app/service/backend_service.dart';
import 'package:fimber/fimber.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class LogService {
  static const _rolloverTimeMinutes = 1;
  static const _maxFileSize = 50 * 1024;
  static const _prefix = 'das-log';
  static const _lastSavedFileName = '$_prefix-lastSavedFile.json';
  final _lock = Lock();
  final _senderLock = Lock();

  late final Future<void> _initialized;
  late String _logPath;

  DateTime _nextRolloverTimeStamp = DateTime.now().add(const Duration(minutes: _rolloverTimeMinutes));

  LogService() {
    _initialized = _init();
  }

  Future<void> _init() async {
    Fimber.i('Initializing LogService...');
    _logPath = await _getLogPath();
  }

  Future<String> _getLogPath() async {
    return '${(await getApplicationSupportDirectory()).path}/logs';
  }

  void save(LogEntry log) {
    _saveInternal(log);
  }

  void _saveInternal(LogEntry log) async {
    await _initialized;
    _lock.synchronized(() {
      final lastSavedFile = File('$_logPath/$_lastSavedFileName');
      if (!(lastSavedFile.existsSync())) {
        lastSavedFile.createSync(recursive: true);
      }
      lastSavedFile.writeAsStringSync('${jsonEncode(log)},', mode: FileMode.append);

      // Check rollover
      if (lastSavedFile.lengthSync() > _maxFileSize || _nextRolloverTimeStamp.isBefore(DateTime.now())) {
        Fimber.d('Rolling over log file');
        lastSavedFile.renameSync('$_logPath/$_prefix-${DateTime.now().millisecondsSinceEpoch}.json');
        _nextRolloverTimeStamp = DateTime.now().add(const Duration(minutes: _rolloverTimeMinutes));
        _sendLogs();
      }
    });
  }

  void _sendLogs() async {
    _senderLock.synchronized(() async {
      final logDir = Directory(_logPath);
      final files = logDir.listSync();
      Fimber.d('Found ${files.length} log files in log directory: $_logPath');

      for (final file in files) {
        if (file is File && file.path.endsWith('.json') && !file.path.contains(_lastSavedFileName)) {
          Fimber.d('Sending ${file.path} to backend');

          var content = file.readAsStringSync();
          content = '[${content.substring(0, content.length - 1)}]'; // Remove trailing comma

          final Iterable iterable = json.decode(content);
          final List<LogEntry> logEntries = List<LogEntry>.from(iterable.map((json) => LogEntry.fromJson(json)));

          final backendService = DI.get<BackendService>();
          if (await backendService.sendLogs(logEntries)) {
            Fimber.d('Deleting ${file.path}');
            file.deleteSync();
          }
        }
      }
    });
  }
}
