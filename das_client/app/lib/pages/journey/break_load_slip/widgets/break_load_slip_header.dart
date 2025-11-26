import 'package:flutter/cupertino.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHeader extends StatelessWidget {
  const BreakLoadSlipHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBHeaderbox(
      title: 'Zug und Bremsreihe: A 80%',
      secondaryLabel: 'Erstellt am 12.06.2024 um 14:30 Uhr',
      flap: SBBHeaderboxFlap.custom(
        child: Row(
          children: [Text('Zug mit gefährlichen Gütern')],
        ),
      ),
    );
  }
}
