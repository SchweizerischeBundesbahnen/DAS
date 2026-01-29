import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipBrakeDetails extends StatelessWidget {
  const BreakLoadSlipBrakeDetails({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return SBBContentBox(
      child: _brakeDetails(context),
    );
  }

  Widget _brakeDetails(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow.title(
          context.l10n.p_break_load_slip_brake_details_title,
          hasChange: _hasChange(),
        ),
        SizedBox(height: SBBSpacing.xSmall),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_brake_ratio_front,
          formationRunChange.formationRun.gradientUphillMaxInPermille.toString(),
          hasChange: formationRunChange.hasChanged(.gradientUphillMaxInPermille),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_brake_ratio_back,
          formationRunChange.formationRun.gradientDownhillMaxInPermille.toString(),
          hasChange: formationRunChange.hasChanged(.gradientDownhillMaxInPermille),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_brake_details_min_holding_force,
          formationRunChange.formationRun.slopeMaxForHoldingForceMinInPermille,
          hasChange: formationRunChange.hasChanged(.slopeMaxForHoldingForceMinInPermille),
        ),
        KeyValueTableDataRow.empty(),
      ],
    );
  }

  bool _hasChange() {
    return formationRunChange.hasChanged(.gradientUphillMaxInPermille) ||
        formationRunChange.hasChanged(.gradientDownhillMaxInPermille) ||
        formationRunChange.hasChanged(.slopeMaxForHoldingForceMinInPermille);
  }
}
