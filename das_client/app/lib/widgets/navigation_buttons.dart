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
      margin: EdgeInsets.only(bottom: sbbDefaultSpacing * 2),
      padding: EdgeInsets.all(sbbDefaultSpacing / 2),
      decoration: _navigationButtonsDecoration(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SBBIconButtonLarge(
            key: navigationButtonPreviousKey,
            icon: SBBIcons.chevron_left_small,
            onPressed: onPreviousPressed,
          ),
          SizedBox(width: sbbDefaultSpacing),
          SBBPagination(
            numberPages: numberPages,
            currentPage: currentPage,
          ),
          SizedBox(width: sbbDefaultSpacing),
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
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    return ShapeDecoration(
      shape: StadiumBorder(),
      color: isDark ? SBBColors.granite : SBBColors.milk,
      shadows: [
        BoxShadow(
          blurRadius: sbbDefaultSpacing / 2,
          color: isDark ? SBBColors.white.withValues(alpha: .4) : SBBColors.black.withValues(alpha: .2),
        ),
      ],
    );
  }
}
