import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class MicrophoneIconButton extends StatelessWidget {
  const MicrophoneIconButton({
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
      child: Container(
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
    );
  }
}
