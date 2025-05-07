import 'dart:io';
import 'package:flutter/services.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:fimber/fimber.dart';
import 'package:android_intent_plus/android_intent.dart';

class BrightnessManagerImpl implements BrightnessManager {
  BrightnessManagerImpl(this._screenBrightness);

  final ScreenBrightness _screenBrightness;

  final double minBrightness = 0.0;
  final double maxBrightness = 1.0;
  final double fallbackBrightness = 0.1;
  final String brightnessManagerChannel = 'brightness_manager';
  final String manageWriteSettingsAction = 'android.settings.action.MANAGE_WRITE_SETTINGS';

  @override
  Future<bool> hasWriteSettingsPermission() async {
    if (Platform.isIOS) return true;
    final platform = MethodChannel(brightnessManagerChannel);
    try {
      return await platform.invokeMethod('canWriteSettings') as bool;
    } catch (e) {
      Fimber.e('Error checking canWriteSettings', ex: e);
      return false;
    }
  }

  @override
  Future<void> requestWriteSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: manageWriteSettingsAction,
      );
      await intent.launch();
    }
  }

  Future<bool> _ensureWriteSettingsOrTrap() async {
    if (Platform.isIOS) return true;

    bool permissionGranted = await hasWriteSettingsPermission();
    if (!permissionGranted) {
      await requestWriteSettings();
      permissionGranted = await hasWriteSettingsPermission();
    }
    return permissionGranted;
  }

  @override
  Future<void> setBrightness(double value) async {
    try {
      final permissionGranted = await _ensureWriteSettingsOrTrap();
      if (!permissionGranted) {
        Fimber.e('Cannot set brightness: write settings permission denied');
        return;
      }
      await _screenBrightness.setSystemScreenBrightness(value.clamp(minBrightness, maxBrightness));
    } catch (e) {
      Fimber.e('Failed to set brightness', ex: e);
    }
  }

  @override
  Future<double> getCurrentBrightness() async {
    try {
      return await _screenBrightness.system;
    } catch (e) {
      Fimber.e('Failed to get brightness', ex: e);
      return fallbackBrightness;
    }
  }
}
