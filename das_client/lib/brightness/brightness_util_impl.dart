import 'package:das_client/brightness/brightness_util.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessUtilImpl implements BrightnessUtil {
  static const MethodChannel _channel = MethodChannel('brightness/util');

  Future<bool> _hasWritePermission() async {
    try {
      return await _channel.invokeMethod('canWriteSettings');
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestWritePermission() async {
    try {
      await _channel.invokeMethod('requestWriteSettings');
    } catch (_) {}
  }

  @override
  Future<void> setBrightness(double value) async {
    final hasPermission = await _hasWritePermission();
    if (!hasPermission) {
      await _requestWritePermission();
      return;
    }

    try {
      await ScreenBrightness().setSystemScreenBrightness(value.clamp(0.0, 1.0));
    } catch (_) {}
  }

  @override
  Future<double> getCurrentBrightness() async {
    try {
      return await ScreenBrightness().system;
    } catch (_) {
      return 0.1;
    }
  }
}
