import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ExclamationIconButton extends StatelessWidget {
  const ExclamationIconButton({
    required this.icon,
    this.onTap,
    super.key,
  });

  final VoidCallback? onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: .none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SBBColors.cloud,
            ),
            width: 32,
            height: 32,
            child: Center(
              child: SvgPicture.asset(icon),
            ),
          ),
          Positioned(top: -7, right: -12, child: SvgPicture.asset(AppAssets.iconExclamationPoint)),
        ],
      ),
    );
  }
}
