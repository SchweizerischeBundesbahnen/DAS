import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class TimeContainer extends StatelessWidget {
  const TimeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
      padding: const EdgeInsets.all(16),
      useShadow: false,
      child: SizedBox(
        width: 124.0,
        height: 112.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '05:43:00',
              style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0),
            ),
            _divider(),
            Text(
              '+00:01:30',
              style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }
}
