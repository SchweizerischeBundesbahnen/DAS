import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_train_data_table.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipTrainData extends StatelessWidget {
  const BreakLoadSlipTrainData({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: SBBGroup(
        child: Row(
          spacing: sbbDefaultSpacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _trainDataColumn1(context)),
            Expanded(flex: 3, child: _trainDataColumn2(context)),
            Expanded(flex: 5, child: _trainDataColumn3(context)),
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
          _dataRow(context.l10n.p_break_load_slip_train_data_title, null, labelStyle: DASTextStyles.smallBold),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          _dataRow(context.l10n.p_break_load_slip_train_data_train_number, '62159'),
          _dataRow(context.l10n.p_break_load_slip_train_data_date, '27.01.2025'),
          _dataRow(context.l10n.p_break_load_slip_train_data_from, 'Graftal'),
          _dataRow(context.l10n.p_break_load_slip_train_data_to, 'Twinn'),
          _dataRow(context.l10n.p_break_load_slip_train_data_train_series, 'A 80%'),
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
          _dataRow(' ', null, labelStyle: DASTextStyles.smallBold),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          _dataRow(context.l10n.p_break_load_slip_train_data_train_traction, 'Q (420) und P (843)'),
          _dataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_leading_traction, 'Ja'),
          _dataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_break_unit, 'Nein'),
          _dataRow(context.l10n.p_break_load_slip_train_data_brake_position_g_load_hauled, 'Nein'),
        ],
      ),
    );
  }

  Widget _trainDataColumn3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(right: 0.0),
      child: BreakLoadSlipTrainDataTable(),
    );
  }

  Row _dataRow(
    String label,
    String? value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? DASTextStyles.smallRoman,
        ),
        Text(
          value ?? '',
          style: valueStyle ?? DASTextStyles.smallRoman,
        ),
      ],
    );
  }
}
