import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeManager(BuildContext context) : _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final currentBrightness = SBBBaseStyle.of(context).brightness;
      _themeMode = currentBrightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }
}
