import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_train_details_table.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BreakLoadSlipTrainDetails extends StatelessWidget {
  const BreakLoadSlipTrainDetails({required this.formation, required this.formationRun, super.key});

  final Formation formation;
  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
      child: SBBGroup(
        child: Row(
          spacing: sbbDefaultSpacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _trainDataColumn1(context)),
            Expanded(flex: 3, child: _trainDataColumn2(context)),
            Expanded(flex: 4, child: _trainDataColumn3(context)),
          ],
        ),
      ),
    );
  }

  Widget _trainDataColumn1(BuildContext context) {
    final vm = context.read<BreakLoadSlipViewModel>();

    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_title,
            null,
            labelStyle: DASTextStyles.smallBold,
          ),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_train_number,
            formation.operationalTrainNumber,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_date,
            DateFormat('yyyy.MM.dd').format(formation.operationalDay),
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_from,
            vm.resolveStationName(formationRun.tafTapLocationReferenceStart),
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_to,
            vm.resolveStationName(formationRun.tafTapLocationReferenceEnd),
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_train_series,
            '${formationRun.trainCategoryCode ?? ''} ${formationRun.brakedWeightPercentage ?? ''}%',
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_other_data_rru,
            _resolveCompanyCode(context, formation.company),
          ),
        ],
      ),
    );
  }

  String _resolveCompanyCode(BuildContext context, String companyCode) {
    final ru = RailwayUndertaking.fromCompanyCode(companyCode);
    return ru != RailwayUndertaking.unknown ? ru.displayText(context) : companyCode;
  }

  Widget _trainDataColumn2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty row for alignment with other columns
          BreakLoadSlipDataRow(' ', null, labelStyle: DASTextStyles.smallBold),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_train_traction,
            formationRun.additionalTractions.isEmpty ? '-' : formationRun.additionalTractions.join(' '),
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_brake_position_g_leading_traction,
            formationRun.brakePositionGForLeadingTraction == true ? context.l10n.c_yes : context.l10n.c_no,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_brake_position_g_break_unit,
            formationRun.brakePositionGForBrakeUnit1to5 == true ? context.l10n.c_yes : context.l10n.c_no,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_train_data_brake_position_g_load_hauled,
            formationRun.brakePositionGForLoadHauled == true ? context.l10n.c_yes : context.l10n.c_no,
          ),
        ],
      ),
    );
  }

  Widget _trainDataColumn3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(right: 0.0),
      child: BreakLoadSlipTrainDetailsTable(formationRun: formationRun),
    );
  }
}
