import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const String _dash = '\u{2013}';

  const AdvisedSpeedCellBody({
    required this.speed,
    this.isSpeedReducedDueToLineSpeed = false,
    super.key,
  });

  final SingleSpeed speed;
  final bool isSpeedReducedDueToLineSpeed;

  @override
  Widget build(BuildContext context) {
    final resolvedAdvisedSpeed = speed.value == '0' ? _dash : speed.value;
    return Text(
      key: key,
      resolvedAdvisedSpeed,
      style: isSpeedReducedDueToLineSpeed ? DASTextStyles.largeLight.copyWith(color: SBBColors.metal) : null,
    );
  }
}
