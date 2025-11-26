import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipOtherData extends StatelessWidget {
  const BreakLoadSlipOtherData({required this.formation, required this.formationRun, super.key});

  final Formation formation;
  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_other_data_title,
              null,
              labelStyle: DASTextStyles.smallBold,
            ),
            SizedBox(height: sbbDefaultSpacing * 0.5),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_other_data_valid_from,
              '-',
            ),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_other_data_rru, formation.company),
            BreakLoadSlipDataRow('', ''),
          ],
        ),
      ),
    );
  }
}
