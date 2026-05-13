import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ThemeUtil {
  const ThemeUtil._();

  static Color getColor(BuildContext context, Color bright, Color dark) {
    return Theme.of(context).sbbBaseStyle.themeValue(bright, dark);
  }

  static Color getIconColor(BuildContext context) => Theme.of(context).sbbBaseStyle.colorScheme.iconPrimary!;

  static Color getDASTableColor(BuildContext context) => getColor(context, SBBColors.white, SBBColors.charcoal);

  static Color getDASTableBorderColor(BuildContext context) => getColor(context, SBBColors.cloud, SBBColors.iron);

  static Color getBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == .dark;
}
