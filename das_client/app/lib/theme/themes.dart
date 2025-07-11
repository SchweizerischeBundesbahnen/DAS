import 'package:app/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DASTheme {
  const DASTheme._();

  static SBBBaseStyle baseStyle([Brightness brightness = Brightness.light]) => SBBBaseStyle(
    primarySwatch: SBBColors.royal.toSingleMaterialColor(),
    primaryColor: SBBColors.royal,
    primaryColorDark: SBBColors.royal125,
    brightness: brightness,
  );

  static ThemeData light() => SBBTheme.light(baseStyle: baseStyle());

  static ThemeData dark() => SBBTheme.dark(baseStyle: baseStyle(Brightness.dark));
}
