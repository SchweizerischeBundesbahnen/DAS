import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_train_details_table.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipTrainDetails extends StatelessWidget {
  const BreakLoadSlipTrainDetails({super.key});

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
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_train_number, '62159'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_date, '27.01.2025'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_from, 'Graftal'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_to, 'Twinn'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_train_series, 'A 80%'),
        ],
      ),
    );
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
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_train_traction, 'Q (420) und P (843)'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_leading_traction, 'Ja'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_break_unit, 'Nein'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_load_hauled, 'Nein'),
        ],
      ),
    );
  }

  Widget _trainDataColumn3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(right: 0.0),
      child: BreakLoadSlipTrainDetailsTable(),
    );
  }
}
