import 'package:app/i18n/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHeader extends StatelessWidget {
  const BreakLoadSlipHeader({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return SBBHeaderbox(
      title: context.l10n.p_break_load_slip_header_title(
        formationRun.trainCategoryCode ?? '',
        formationRun.brakedWeightPercentage ?? '',
      ),
      secondaryLabel: context.l10n.p_break_load_slip_header_subtitle(
        DateFormat('yyyy.MM.dd HH:mm').format(formationRun.inspectionDateTime),
      ),
      flap: SBBHeaderboxFlap.custom(
        child: Row(
          children: [Text('Zug mit gefährlichen Gütern')],
        ),
      ),
    );
  }
}
