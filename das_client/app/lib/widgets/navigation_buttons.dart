import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class NavigationButtons extends StatelessWidget {
  static const Key navigationButtonKey = Key('navigationButton');
  static const Key navigationButtonPreviousKey = Key('navigationButtonPrevious');
  static const Key navigationButtonNextKey = Key('navigationButtonNext');

  const NavigationButtons({
    required this.currentPage,
    required this.numberPages,
    super.key,
    this.onNextPressed,
    this.onPreviousPressed,
  });

  final int currentPage;
  final int numberPages;
  final VoidCallback? onNextPressed;
  final VoidCallback? onPreviousPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: navigationButtonKey,
      margin: EdgeInsets.only(bottom: SBBSpacing.xLarge),
      padding: EdgeInsets.all(SBBSpacing.xSmall),
      decoration: _navigationButtonsDecoration(context),
      child: Row(
        mainAxisSize: .min,
        spacing: SBBSpacing.medium,
        children: [
          SBBIconButtonLarge(
            key: navigationButtonPreviousKey,
            icon: SBBIcons.chevron_left_small,
            onPressed: onPreviousPressed,
          ),
          SBBPagination(
            numberPages: numberPages,
            currentPage: currentPage,
          ),
          SBBIconButtonLarge(
            key: navigationButtonNextKey,
            icon: SBBIcons.chevron_right_small,
            onPressed: onNextPressed,
          ),
        ],
      ),
    );
  }

  ShapeDecoration _navigationButtonsDecoration(BuildContext context) {
    final isDark = ThemeUtil.isDarkMode(context);
    return ShapeDecoration(
      shape: StadiumBorder(),
      color: isDark ? SBBColors.granite : SBBColors.milk,
      shadows: [
        BoxShadow(
          blurRadius: SBBSpacing.xSmall,
          color: isDark ? SBBColors.white.withValues(alpha: .4) : SBBColors.black.withValues(alpha: .2),
        ),
      ],
    );
  }
}
