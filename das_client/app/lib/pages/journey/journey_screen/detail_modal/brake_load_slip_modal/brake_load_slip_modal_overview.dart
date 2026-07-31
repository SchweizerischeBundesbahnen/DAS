import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipModalOverview extends StatelessWidget {
  const BrakeLoadSlipModalOverview({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

    return SBBContentBox(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight),
      child: KeyValueTable(
        rows: [
          KeyValueTableDataRow.title(context.l10n.w_brake_load_slip_modal_overview_title),
          SizedBox(height: SBBSpacing.xSmall),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_from,
            viewModel.resolveStationName(formationRunChange.formationRun.tafTapLocationReferenceStart),
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_to,
            viewModel.resolveStationName(formationRunChange.formationRun.tafTapLocationReferenceEnd),
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_train_series,
            '${formationRunChange.formationRun.trainCategoryCode ?? ''} ${formationRunChange.formationRun.brakedWeightPercentage ?? ''}%',
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_table_vmax,
            formationRunChange.formationRun.formationMaxSpeedInKmh.toString(),
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_table_length,
            (formationRunChange.formationRun.formationLengthInCm / 100).toString(),
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_table_weight,
            formationRunChange.formationRun.formationWeightInT.toString(),
            showChangeIndicator: false,
          ),
          KeyValueTableDataRow(
            context.l10n.p_brake_load_slip_train_data_table_braked_weight,
            formationRunChange.formationRun.formationBrakedWeightInT.toString(),
            showChangeIndicator: false,
          ),
        ],
      ),
    );
  }
}
