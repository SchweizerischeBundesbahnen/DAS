import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class PunctualityDisplay extends StatelessWidget {
  const PunctualityDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('05:43:00', style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0)),
          const SizedBox(width: 8.0),
          Text('+00:01:30', style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
        ],
      ),
    );
  }
}
