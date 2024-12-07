import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class DepartureAuthorization extends StatelessWidget {
  const DepartureAuthorization({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(SBBIcons.circle_tick_small),
        const SizedBox(width: sbbDefaultSpacing * 0.5),
        Text('SMS', style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
      ],
    );
  }
}
