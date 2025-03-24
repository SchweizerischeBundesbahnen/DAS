import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DASTextStyles {
  DASTextStyles._();

  static const double xLargeFontSize = 24.0;
  static const double xLargeFontHeight = 32.0 / xLargeFontSize;

  static const double xxLargeFontSize = 30.0;
  static const double xxLargeFontHeight = 32.0 / xxLargeFontSize;

  static const TextStyle xxLargeBold = TextStyle(
    fontSize: xxLargeFontSize,
    height: xxLargeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    fontFamily: SBBFontFamily.sbbFontBold,
  );

  static const TextStyle xLargeBold = TextStyle(
    fontSize: xLargeFontSize,
    height: xLargeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    fontFamily: SBBFontFamily.sbbFontBold,
  );

  static const TextStyle xLargeRoman = TextStyle(
    fontSize: xLargeFontSize,
    height: xLargeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    fontFamily: SBBFontFamily.sbbFontRoman,
  );

  static const TextStyle xLargeLight = TextStyle(
    fontSize: xLargeFontSize,
    height: xLargeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w300,
    fontFamily: SBBFontFamily.sbbFontLight,
  );

  static const TextStyle largeBold = SBBTextStyles.largeBold;

  static const TextStyle largeRoman = TextStyle(
    fontSize: SBBTextStyles.largeFontSize,
    height: SBBTextStyles.largeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    fontFamily: SBBFontFamily.sbbFontRoman,
  );

  static const TextStyle largeLight = SBBTextStyles.largeLight;

  static const TextStyle mediumBold = SBBTextStyles.mediumBold;

  static const TextStyle mediumRoman = TextStyle(
    fontSize: SBBTextStyles.mediumFontSize,
    height: SBBTextStyles.mediumFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    fontFamily: SBBFontFamily.sbbFontRoman,
  );

  static const TextStyle mediumLight = SBBTextStyles.mediumLight;

  static const TextStyle smallLight = SBBTextStyles.smallLight;

  static const TextStyle extraSmallBold = SBBTextStyles.extraSmallBold;
}
