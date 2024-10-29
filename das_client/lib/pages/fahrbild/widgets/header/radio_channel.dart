import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class RadioChannel extends StatelessWidget {
  const RadioChannel({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240.0),
      child: Row(
        children: [
          const Icon(SBBIcons.telephone_gsm_small),
          const SizedBox(width: 8.0),
          Text('1311', style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
        ],
      ),
    );
  }
}
