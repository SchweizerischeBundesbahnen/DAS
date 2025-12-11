import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipModalOverview extends StatelessWidget {
  const BreakLoadSlipModalOverview({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight),
      child: KeyValueTable(
        rows: [
          KeyValueTableDataRow.title(context.l10n.w_break_load_slip_modal_overview_title),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_train_data_train_series,
            '${formationRunChange.formationRun.trainCategoryCode ?? ''} ${formationRunChange.formationRun.brakedWeightPercentage ?? ''}%',
            shownChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_train_data_table_vmax,
            formationRunChange.formationRun.formationMaxSpeedInKmh.toString(),
            shownChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_train_data_table_length,
            (formationRunChange.formationRun.formationLengthInCm / 100).toString(),
            shownChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_train_data_table_weight,
            formationRunChange.formationRun.formationWeightInT.toString(),
            shownChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_train_data_table_braked_weight,
            formationRunChange.formationRun.formationBrakedWeightInT.toString(),
            shownChangeIndicator: false,
          ),
        ],
      ),
    );
  }
}
