import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/src/das_logger.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/log_level.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

final _log = Logger('DasLoggerImpl');

class DasLoggerImpl extends DasLogger {
  DasLoggerImpl({required LoggerRepo loggerRepo, required this.deviceId}) : _loggerRepo = loggerRepo {
    _initialized = _init();
  }

  final String deviceId;
  final LoggerRepo _loggerRepo;
  final Map<String, String> metadata = {};
  late Future<void> _initialized;

  Future<void> _init() async {
    _log.fine('Initializing DasLoggerImpl...');
    metadata['deviceId'] = deviceId;

    final info = await PackageInfo.fromPlatform();
    metadata['appVersion'] = info.version;

    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _processAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      _processIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  }

  void _processAndroidDeviceInfo(AndroidDeviceInfo deviceInfo) {
    metadata['systemName'] = 'android';
    metadata['systemVersion'] = deviceInfo.version.sdkInt.toString();
    metadata['model'] = deviceInfo.model;
  }

  void _processIosDeviceInfo(IosDeviceInfo deviceInfo) {
    metadata['systemName'] = deviceInfo.systemName;
    metadata['systemVersion'] = deviceInfo.systemVersion;
    metadata['model'] = deviceInfo.model;
  }

  @override
  void call(LogRecord record) {
    _logInternal(record.level, record.message, tag: record.loggerName, ex: record.error, stacktrace: record.stackTrace);
  }

  void _logInternal(Level level, String message, {String? tag, ex, StackTrace? stacktrace}) async {
    await _initialized;

    final messageBuilder = StringBuffer('$tag:\t $message');

    if (ex != null) {
      messageBuilder.write('\n$ex');
    }
    if (stacktrace != null) {
      final tmpStacktrace = stacktrace.toString().split('\n');
      final stackTraceMessage = tmpStacktrace.map((stackLine) => '\t$stackLine').join('\n');
      messageBuilder.write('\n$stackTraceMessage');
    }

    // TODO: commented out due to issue when log endpoint not reachable (client becomes slow)
    // add back with https://github.com/SchweizerischeBundesbahnen/DAS/issues/1007
    // _loggerRepo.saveLog(LogEntry(messageBuilder.toString(), _getLogLevel(level), metadata));
  }

  LogLevel _getLogLevel(Level level) {
    return switch (level.value) {
      700 => LogLevel.debug,
      800 => LogLevel.info,
      900 => LogLevel.warning,
      1000 => LogLevel.error,
      1200 => LogLevel.fatal,
      _ => LogLevel.trace,
    };
  }
}
