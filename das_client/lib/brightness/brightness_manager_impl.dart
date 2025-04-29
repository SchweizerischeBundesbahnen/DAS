import 'dart:io';
import 'package:flutter/services.dart';
import 'package:das_client/brightness/brightness_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:fimber/fimber.dart';
import 'package:android_intent_plus/android_intent.dart';

class BrightnessManagerImpl implements BrightnessManager {
  final ScreenBrightness _screenBrightness;

  BrightnessManagerImpl(this._screenBrightness);

  @override
  Future<bool> hasWriteSettingsPermission() async {
    if (Platform.isIOS) return true;
    const platform = MethodChannel('brightness_manager');
    try {
      return await platform.invokeMethod('canWriteSettings') as bool;
    } catch (e) {
      Fimber.e('Error checking canWriteSettings: $e');
      return false;
    }
  }

  @override
  Future<void> requestWriteSettings() async {
    if (Platform.isAndroid) {
      final intent = const AndroidIntent(
        action: 'android.settings.action.MANAGE_WRITE_SETTINGS',
      );
      await intent.launch();
    }
  }

  Future<void> _ensureWriteSettingsOrTrap() async {
    if (Platform.isIOS) return;
    var permissionGranted = await hasWriteSettingsPermission();
    if (!permissionGranted) {
      await requestWriteSettings();

      while (!permissionGranted) {
        permissionGranted = await hasWriteSettingsPermission();
      }
    }
  }

  @override
  Future<void> setBrightness(double value) async {
    try {
      await _ensureWriteSettingsOrTrap();
      await _screenBrightness.setSystemScreenBrightness(value.clamp(0.0, 1.0));
    } catch (e) {
      Fimber.e('Failed to set brightness: $e');
    }
  }

  @override
  Future<double> getCurrentBrightness() async {
    try {
      return await _screenBrightness.system;
    } catch (e) {
      Fimber.e('Failed to get brightness: $e');
      return 0.1;
    }
  }
}
