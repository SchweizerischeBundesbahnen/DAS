import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceIdInfo {
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    _deviceId ??= await _findDeviceId();
    return _deviceId!.toLowerCase();
  }

  static Future<String?> _findDeviceId() async {
    if (Platform.isAndroid) {
      return _androidDeviceId();
    } else if (Platform.isIOS) {
      return _iosDeviceId();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return const Uuid().v4();
    }
    return Future.value(null);
  }

  static Future<String> _androidDeviceId() async {
    final androidId = await AndroidId().getId();
    return androidId ?? (await DeviceInfoPlugin().androidInfo).id;
  }

  static Future<String> _iosDeviceId() async {
    final deviceInfo = await DeviceInfoPlugin().iosInfo;
    return deviceInfo.identifierForVendor ?? const Uuid().v4();
  }
}
