import 'dart:io';

import 'package:app/util/device_id_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/log_entry.dart';
import 'package:logger/src/log_level.dart';

class DasLogTree extends LogTree {
  DasLogTree({required LoggerRepo loggerRepo}) : _loggerRepo = loggerRepo {
    _initialized = _init();
  }

  final LoggerRepo _loggerRepo;
  final Map<String, String> metadata = {};
  late Future<void> _initialized;

  Future<void> _init() async {
    Fimber.i('Initializing DasLogTree...');
    metadata['deviceId'] = await DeviceIdInfo.getDeviceId();

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
  List<String> getLevels() {
    return ['I', 'W', 'E'];
  }

  @override
  void log(String level, String message, {String? tag, ex, StackTrace? stacktrace}) {
    logInternal(level, message, tag: tag ?? LogTree.getTag(), ex: ex, stacktrace: stacktrace);
  }

  void logInternal(String level, String message, {String? tag, ex, StackTrace? stacktrace}) async {
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

    _loggerRepo.saveLog(LogEntry(messageBuilder.toString(), _getLogLevel(level), metadata));
  }

  LogLevel _getLogLevel(String level) {
    switch (level) {
      case 'D':
        return LogLevel.debug;
      case 'W':
        return LogLevel.warning;
      case 'E':
        return LogLevel.error;
      case 'V':
        return LogLevel.trace;
      case 'I':
      default:
        return LogLevel.info;
    }
  }
}
