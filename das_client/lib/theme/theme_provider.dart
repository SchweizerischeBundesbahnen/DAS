import 'package:flutter/material.dart';

class ThemeManager extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const ThemeManager({
    required this.themeMode, required this.toggleTheme, required super.child, super.key,
  });

  static ThemeManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManager>();
  }

  @override
  bool updateShouldNotify(ThemeManager oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}