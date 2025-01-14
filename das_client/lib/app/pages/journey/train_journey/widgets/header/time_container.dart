import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class TimeContainer extends StatelessWidget {
  const TimeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(
        sbbDefaultSpacing * 0.5,
        0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing,
      ),
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: SizedBox(
        width: 124.0,
        height: 112.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('05:43:00', style: DASTextStyles.xLargeBold),
            _divider(),
            Text('+00:01:30', style: DASTextStyles.xLargeLight),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }
}
