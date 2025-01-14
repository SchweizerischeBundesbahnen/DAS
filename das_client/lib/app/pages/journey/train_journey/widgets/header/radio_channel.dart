import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class RadioChannel extends StatelessWidget {
  const RadioChannel({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 258.0),
      child: Row(
        children: [
          const Icon(SBBIcons.telephone_gsm_small),
          const SizedBox(width: sbbDefaultSpacing * 0.5),
          Text('1311', style: DASTextStyles.largeRoman),
        ],
      ),
    );
  }
}
