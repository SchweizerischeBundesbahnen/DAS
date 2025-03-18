import 'package:flutter/cupertino.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Util {
  static int? tryParseInt(String? value) {
    return value != null ? int.tryParse(value) : null;
  }

  static double? tryParseDouble(String? value) {
    return value != null ? double.tryParse(value) : null;
  }

  static DateTime? tryParseDateTime(String? value) {
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Color getColor(BuildContext context) {
    return SBBBaseStyle.of(context).themeValue(SBBColors.black, SBBColors.white);
  }
}
