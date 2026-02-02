import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_train_details_table.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BreakLoadSlipTrainDetails extends StatelessWidget {
  const BreakLoadSlipTrainDetails({required this.formation, required this.formationRunChange, super.key});

  final Formation formation;
  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return SBBContentBox(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _trainDataRow1(context),
          Divider(),
          _trainDataRow2(context),
          Divider(),
          _trainDataRow3(context),
        ],
      ),
    );
  }

  Widget _trainDataRow1(BuildContext context) {
    final vm = context.read<BreakLoadSlipViewModel>();

    return KeyValueTable(
      rows: [
        KeyValueTableDataRow.title(
          context.l10n.p_break_load_slip_train_data_title,
          hasChange: _hasChange(),
        ),
        SizedBox(height: SBBSpacing.xSmall),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_train_number,
          formation.operationalTrainNumber,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_date,
          DateFormat('yyyy.MM.dd').format(formation.operationalDay),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_from,
          vm.resolveStationName(formationRunChange.formationRun.tafTapLocationReferenceStart),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_to,
          vm.resolveStationName(formationRunChange.formationRun.tafTapLocationReferenceEnd),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_train_series,
          '${formationRunChange.formationRun.trainCategoryCode ?? ''} ${formationRunChange.formationRun.brakedWeightPercentage ?? ''}%',
          hasChange:
              formationRunChange.hasChanged(.trainCategoryCode) ||
              formationRunChange.hasChanged(.brakedWeightPercentage),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_other_data_rru,
          _resolveCompanyCode(context, formation.company),
        ),
      ],
    );
  }

  String _resolveCompanyCode(BuildContext context, String companyCode) {
    final ru = RailwayUndertaking.fromCompanyCode(companyCode);
    return ru != RailwayUndertaking.unknown ? ru.displayText(context) : companyCode;
  }

  Widget _trainDataRow2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SBBSpacing.xSmall),
      child: BreakLoadSlipTrainDetailsTable(formationRunChange: formationRunChange),
    );
  }

  Widget _trainDataRow3(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_train_traction,
          formationRunChange.formationRun.additionalTractions.isEmpty
              ? '-'
              : formationRunChange.formationRun.additionalTractions.join(' '),
          hasChange: formationRunChange.hasChanged(.additionalTractions),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_brake_position_g_leading_traction,
          formationRunChange.formationRun.brakePositionGForLeadingTraction == true
              ? context.l10n.c_yes
              : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForLeadingTraction),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_brake_position_g_break_unit,
          formationRunChange.formationRun.brakePositionGForBrakeUnit1to5 == true
              ? context.l10n.c_yes
              : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForBrakeUnit1to5),
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_train_data_brake_position_g_load_hauled,
          formationRunChange.formationRun.brakePositionGForLoadHauled == true ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForLoadHauled),
        ),
      ],
    );
  }

  bool _hasChange() {
    return formationRunChange.hasChanged(.tractionMaxSpeedInKmh) ||
        formationRunChange.hasChanged(.hauledLoadMaxSpeedInKmh) ||
        formationRunChange.hasChanged(.formationMaxSpeedInKmh) ||
        formationRunChange.hasChanged(.tractionLengthInCm) ||
        formationRunChange.hasChanged(.hauledLoadLengthInCm) ||
        formationRunChange.hasChanged(.formationLengthInCm) ||
        formationRunChange.hasChanged(.tractionWeightInT) ||
        formationRunChange.hasChanged(.hauledLoadWeightInT) ||
        formationRunChange.hasChanged(.formationWeightInT) ||
        formationRunChange.hasChanged(.tractionBrakedWeightInT) ||
        formationRunChange.hasChanged(.hauledLoadBrakedWeightInT) ||
        formationRunChange.hasChanged(.formationBrakedWeightInT) ||
        formationRunChange.hasChanged(.additionalTractions) ||
        formationRunChange.hasChanged(.brakePositionGForLeadingTraction) ||
        formationRunChange.hasChanged(.brakePositionGForBrakeUnit1to5) ||
        formationRunChange.hasChanged(.brakePositionGForLoadHauled) ||
        formationRunChange.hasChanged(.trainCategoryCode) ||
        formationRunChange.hasChanged(.brakedWeightPercentage);
  }
}
