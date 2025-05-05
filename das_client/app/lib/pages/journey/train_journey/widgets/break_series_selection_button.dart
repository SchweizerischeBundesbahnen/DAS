import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakSeriesSelectionButton extends StatelessWidget {
  const BreakSeriesSelectionButton(
      {required this.label, required this.currentlySelected, required this.onTap, super.key});

  final String label;
  final bool currentlySelected;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: currentlySelected
                  ? ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite)
                  : ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron),
            ),
            width: 72,
            height: 48,
            child: Center(
              child: Text(
                label,
                style: DASTextStyles.mediumBold.copyWith(
                  color: currentlySelected
                      ? ThemeUtil.getFontColor(context)
                      : ThemeUtil.getColor(
                          context,
                          SBBColors.black,
                          SBBColors.white,
                        ),
                ),
              ),
            ),
          ),
          if (currentlySelected) Positioned(top: -6, right: -6, child: SvgPicture.asset(AppAssets.iconIndicatorChecked))
        ],
      ),
    );
  }
}
