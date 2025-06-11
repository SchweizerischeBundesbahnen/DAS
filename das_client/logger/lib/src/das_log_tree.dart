import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/src/data/logger_repo.dart';
import 'package:logger/src/log_entry.dart';
import 'package:logger/src/log_level.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DasLogTree extends LogTree implements ShadowChangeHandlers {
  DasLogTree({required LoggerRepo loggerRepo, required this.deviceId}) : _loggerRepo = loggerRepo {
    _initialized = _init();
  }

  final String deviceId;
  final LoggerRepo _loggerRepo;
  final Map<String, String> metadata = {};
  late Future<void> _initialized;

  Future<void> _init() async {
    Fimber.d('Initializing DasLogTree...');
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

  @override
  void onGetShadowed(Object shadowing) {
    Fimber.d('This tree is being shadowed - unplanting this and planting new tree with shadowing');
    Fimber.unplantTree(this);
    Fimber.plantTree(shadowing as LogTree);
  }

  @override
  void onLeaveShadow(Object shadowing) {
    Fimber.d('This tree is not shadowed anymore - unplanting shadow and planting this tree');
    Fimber.unplantTree(shadowing as LogTree);
    Fimber.plantTree(this);
  }
}
