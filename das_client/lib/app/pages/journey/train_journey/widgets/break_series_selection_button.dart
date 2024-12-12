import 'package:das_client/app/widgets/assets.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BreakSeriesSelectionButton extends StatelessWidget {
  const BreakSeriesSelectionButton(
      {required this.label, required this.currentlySelected, required this.onTap, super.key});

  final String label;
  final bool currentlySelected;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: currentlySelected ? SBBColors.granite : SBBColors.cloud,
            ),
            width: 72,
            height: 48,
            child: Center(
                child: Text(
              label,
              style: SBBTextStyles.mediumBold.copyWith(color: currentlySelected ? SBBColors.white : SBBColors.black),
            )),
          ),
          if (currentlySelected) Positioned(top: -6, right: -6, child: SvgPicture.asset(AppAssets.iconIndicatorChecked))
        ],
      ),
    );
  }
}
