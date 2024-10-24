import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class NextStop extends StatelessWidget {
  const NextStop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(SBBIcons.station_small),
        const SizedBox(width: 8.0),
        Text('Baden', style: SBBTextStyles.largeLight),
      ],
    );
  }
}
