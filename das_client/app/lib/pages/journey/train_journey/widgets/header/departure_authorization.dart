import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DepartureAuthorization extends StatelessWidget {
  const DepartureAuthorization({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          SBBIcons.circle_tick_small,
          color: ThemeUtil.getIconColor(context),
        ),
        const SizedBox(width: sbbDefaultSpacing * 0.5),
        Text('', style: DASTextStyles.xLargeRoman),
      ],
    );
  }
}
