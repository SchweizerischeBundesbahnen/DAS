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
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      const androidId = AndroidId();
      return _processAndroidDeviceInfo(await deviceInfoPlugin.androidInfo, await androidId.getId());
    } else if (Platform.isIOS) {
      return _processIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return const Uuid().v4();
    }
    return Future.value(null);
  }

  static String _processAndroidDeviceInfo(AndroidDeviceInfo deviceInfo, String? androidId) {
    return androidId ?? deviceInfo.id;
  }

  static String _processIosDeviceInfo(IosDeviceInfo deviceInfo) {
    return deviceInfo.identifierForVendor ?? const Uuid().v4();
  }
}
