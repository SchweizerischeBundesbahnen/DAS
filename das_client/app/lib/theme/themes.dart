import 'package:app/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final dasLightTheme = SBBTheme.light(
  baseStyle: SBBBaseStyle(
    primarySwatch: SBBColors.royal.toSingleMaterialColor(),
    primaryColor: SBBColors.royal,
    primaryColorDark: SBBColors.royal125,
    brightness: Brightness.light,
  ),
  controlStyles: SBBControlStyles(
    promotionBox:
        PromotionBoxStyle.$default(
          baseStyle: SBBBaseStyle(
            primaryColor: SBBColors.royal,
            primaryColorDark: SBBColors.royal125,
            brightness: Brightness.light,
          ),
        ).copyWith(
          badgeColor: SBBColors.royal,
          badgeShadowColor: SBBColors.royal.withAlpha((255.0 * 0.2).round()),
        ),
  ),
);

final dasDarkTheme = SBBTheme.dark(
  baseStyle: SBBBaseStyle(
    primarySwatch: SBBColors.royal.toSingleMaterialColor(),
    primaryColor: SBBColors.royal,
    primaryColorDark: SBBColors.royal125,
    brightness: Brightness.dark,
  ),
  controlStyles: SBBControlStyles(
    promotionBox:
        PromotionBoxStyle.$default(
          baseStyle: SBBBaseStyle(
            primaryColor: SBBColors.royal,
            primaryColorDark: SBBColors.royal125,
            brightness: Brightness.dark,
          ),
        ).copyWith(
          badgeColor: SBBColors.royal,
          badgeShadowColor: SBBColors.royal.withAlpha((255.0 * 0.2).round()),
          gradientColors: [Color(0xFF0079C7), Color(0xFF143A85), Color(0xFF143A85), Color(0xFF0079C7)],
        ),
  ),
);
