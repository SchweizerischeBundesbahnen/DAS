import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ThemeViewModel {
  static const defaultMode = ThemeMode.system;

  Stream<ThemeMode> get themeMode => _rxThemeMode.stream;

  final _rxThemeMode = BehaviorSubject.seeded(defaultMode);

  void toggleTheme(BuildContext context) {
    ThemeMode newThemeMode;
    if (_rxThemeMode.value == ThemeMode.system) {
      final currentBrightness = SBBBaseStyle.of(context).brightness;
      newThemeMode = currentBrightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
    } else {
      newThemeMode = _rxThemeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    _rxThemeMode.add(newThemeMode);
  }

  void dispose() {
    _rxThemeMode.close();
  }
}
