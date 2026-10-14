import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';

final _log = Logger('BrightnessManagerImpl');

class BrightnessManagerImpl(final ScreenBrightness _screenBrightness) implements BrightnessManager {
  static final double _minBrightness = 0.0;
  static final double _maxBrightness = 1.0;
  static final double _fallbackBrightness = 0.1;
  static final String _brightnessManagerChannel = 'brightness_manager';
  static final String _manageWriteSettingsAction = 'android.settings.action.MANAGE_WRITE_SETTINGS';

  @override
  Future<bool> hasWriteSettingsPermission() async {
    if (Platform.isIOS) return true;
    final platform = MethodChannel(_brightnessManagerChannel);
    try {
      return await platform.invokeMethod('canWriteSettings') as bool;
    } catch (e) {
      _log.severe('Error checking canWriteSettings', e);
      return false;
    }
  }

  @override
  Future<void> requestWriteSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(action: _manageWriteSettingsAction);
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
        _log.severe('Cannot set brightness: write settings permission denied');
        return;
      }
      await _screenBrightness.setSystemScreenBrightness(value.clamp(_minBrightness, _maxBrightness));
    } catch (e) {
      _log.severe('Failed to set brightness', e);
    }
  }

  @override
  Future<double> getCurrentBrightness() async {
    try {
      return await _screenBrightness.system;
    } catch (e) {
      _log.severe('Failed to get brightness', e);
      return _fallbackBrightness;
    }
  }
}
