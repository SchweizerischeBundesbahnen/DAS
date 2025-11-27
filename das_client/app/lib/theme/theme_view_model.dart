import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ThemeViewModel {
  static const defaultMode = ThemeMode.system;

  Stream<ThemeMode> get themeMode => _rxThemeMode.stream;

  final _rxThemeMode = BehaviorSubject.seeded(defaultMode);

  void toggleTheme(BuildContext context) {
    ThemeMode newThemeMode;
    if (_rxThemeMode.value == .system) {
      newThemeMode = ThemeUtil.isDarkMode(context) ? .light : .dark;
    } else {
      newThemeMode = _rxThemeMode.value == .light ? .dark : .light;
    }
    _rxThemeMode.add(newThemeMode);
  }

  void dispose() {
    _rxThemeMode.close();
  }
}
