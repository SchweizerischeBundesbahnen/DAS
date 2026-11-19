import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class MicrophoneIconButton extends StatelessWidget {
  const MicrophoneIconButton({
    required this.icon,
    this.onTap,
    this.showExclamation = false,
    super.key,
  });

  final VoidCallback? onTap;
  final String icon;
  final bool showExclamation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: .none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SBBSpacing.xSmall),
              color: SBBColors.cloud,
            ),
            width: SBBSpacing.xLarge,
            height: SBBSpacing.xLarge,
            child: Center(child: SvgPicture.asset(icon)),
          ),
          if (showExclamation) Positioned(top: -7, right: -12, child: SvgPicture.asset(AppAssets.iconExclamationPoint)),
        ],
      ),
    );
  }
}
