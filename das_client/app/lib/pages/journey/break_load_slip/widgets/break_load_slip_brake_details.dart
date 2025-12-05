import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipBrakeDetails extends StatelessWidget {
  const BreakLoadSlipBrakeDetails({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: _brakeDetails(context),
    );
  }

  Widget _brakeDetails(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow.title(context.l10n.p_break_load_slip_brake_details_title),
        SizedBox(height: sbbDefaultSpacing * 0.5),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_brake_ratio_front,
          formationRun.gradientUphillMaxInPermille.toString(),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_brake_ratio_back,
          formationRun.gradientDownhillMaxInPermille.toString(),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_min_holding_force,
          formationRun.slopeMaxForHoldingForceMinInPermille,
        ),
        KeyValueTableDataRow.empty(),
      ],
    );
  }
}
