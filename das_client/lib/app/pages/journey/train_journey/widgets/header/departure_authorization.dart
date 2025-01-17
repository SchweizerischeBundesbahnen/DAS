import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class DepartureAuthorization extends StatelessWidget {
  const DepartureAuthorization({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(SBBIcons.circle_tick_small),
        const SizedBox(width: sbbDefaultSpacing * 0.5),
        Text('SMS', style: DASTextStyles.largeRoman),
      ],
    );
  }
}
