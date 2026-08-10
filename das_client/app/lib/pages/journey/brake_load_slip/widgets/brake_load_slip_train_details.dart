import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_train_details_table.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipTrainDetails extends StatelessWidget {
  const BrakeLoadSlipTrainDetails({required this.formation, required this.formationRunChange, super.key});

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
    final vm = context.read<BrakeLoadSlipViewModel>();

    return KeyValueTable(
      rows: [
        KeyValueTableDataRow.title(
          context.l10n.p_brake_load_slip_train_data_title,
          hasChange: _hasChange(),
        ),
        SizedBox(height: SBBSpacing.xSmall),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_train_number,
          formation.operationalTrainNumber,
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_date,
          DateFormat('dd.MM.yyyy').format(formation.operationalDay),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_from,
          vm.resolveStationName(_formationRun.tafTapLocationReferenceStart),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_to,
          vm.resolveStationName(_formationRun.tafTapLocationReferenceEnd),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_train_series,
          '${_formationRun.trainCategoryCode ?? ''} ${_formationRun.brakedWeightPercentage ?? ''}%',
          hasChange:
              formationRunChange.hasChanged(.trainCategoryCode) ||
              formationRunChange.hasChanged(.brakedWeightPercentage),
        ),
        _companyShortName(context),
      ],
    );
  }

  Widget _companyShortName(BuildContext context) {
    final vm = context.read<BrakeLoadSlipViewModel>();
    return FutureBuilder(
      future: vm.resolveCompanyName(formation.company),
      builder: (context, snapshot) {
        final companyName = snapshot.data ?? context.l10n.c_unknown;
        return KeyValueTableDataRow(context.l10n.p_brake_load_slip_other_data_rru, companyName);
      },
    );
  }

  Widget _trainDataRow2(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: SBBSpacing.xSmall),
      child: BrakeLoadSlipTrainDetailsTable(formationRunChange: formationRunChange),
    );
  }

  Widget _trainDataRow3(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_train_traction,
          _formationRun.additionalTractions.isEmpty ? '-' : _formationRun.additionalTractions.join(' '),
          hasChange: formationRunChange.hasChanged(.additionalTractions),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_brake_position_g_leading_traction,
          _formationRun.brakePositionGForLeadingTraction == true ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForLeadingTraction),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_brake_position_g_brake_unit,
          _formationRun.brakePositionGForBrakeUnit1to5 == true ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForBrakeUnit1to5),
        ),
        KeyValueTableDataRow(
          context.l10n.p_brake_load_slip_train_data_brake_position_g_load_hauled,
          _formationRun.brakePositionGForLoadHauled == true ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.brakePositionGForLoadHauled),
        ),
      ],
    );
  }

  FormationRun get _formationRun => formationRunChange.formationRun;

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
