import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DASTheme {
  const DASTheme._();

  static SBBBaseStyle baseStyle([Brightness brightness = .light]) => SBBBaseStyle(
    primarySwatch: SBBColors.royal.toSingleMaterialColor(),
    primaryColor: SBBColors.royal,
    primaryColorDark: SBBColors.royal125,
    brightness: brightness,
  );

  static ThemeData light() => SBBTheme.light(baseStyle: baseStyle());

  static ThemeData dark() => SBBTheme.dark(baseStyle: baseStyle(.dark));
}

extension _ColorUtils on Color {
  int toInt() {
    final alpha = (a * 255).toInt();
    final red = (r * 255).toInt();
    final green = (g * 255).toInt();
    final blue = (b * 255).toInt();
    // Combine the components into a single int using bit shifting
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }

  MaterialColor toSingleMaterialColor() {
    return MaterialColor(
      toInt(),
      <int, Color>{
        50: this,
        100: this,
        200: this,
        300: this,
        400: this,
        500: this,
        600: this,
        700: this,
        800: this,
        900: this,
      },
    );
  }
}
