import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ThemeUtil {
  static Color getIconColor(BuildContext context) {
    return SBBBaseStyle.of(context).themeValue(SBBColors.black, SBBColors.white);
  }

  static Color getColor(BuildContext context, Color bright, Color dark) {
    return SBBBaseStyle.of(context).themeValue(bright, dark);
  }

  static Brightness getBrightnessSBBBaseStyle(BuildContext context){
    return SBBBaseStyle.of(context).brightness ?? Brightness.light;
  }

  static Brightness getBrightnessSystem(ThemeMode themeMode){
    return themeMode == ThemeMode.light ? Brightness.light : Brightness.dark;
  }

  static Color getDASTableColor(BuildContext context){
    return SBBBaseStyle.of(context).themeValue(SBBColors.white, SBBColors.charcoal);
  }

  static Color getDASTableBorderColor(BuildContext context){
    return SBBBaseStyle.of(context).themeValue(SBBColors.cloud, SBBColors.iron);
  }

  static Color getFontColor(BuildContext context){
    return SBBBaseStyle.of(context).themeValue(SBBColors.white, SBBColors.charcoal);
  }
}