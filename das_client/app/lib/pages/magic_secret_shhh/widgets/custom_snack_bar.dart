import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class CustomSnackBar {
  static SnackBar build({
    required String label,
    Color textColor = SBBColors.red,
    double fontSize = 30,
  }) {
    return SnackBar(
      closeIconColor: SBBColors.white,
      backgroundColor: SBBColors.charcoal,
      padding: EdgeInsets.all(sbbDefaultSpacing * 1.5),
      content: Center(
        child: Text(
          label,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }
}
