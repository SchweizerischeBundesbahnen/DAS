import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_brake_details_table.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipBrakeDetails extends StatelessWidget {
  const BreakLoadSlipBrakeDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: Row(
        spacing: sbbDefaultSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _brakeDetailsColumn1(context)),
          Expanded(flex: 4, child: _brakeDetailsColumn2(context)),
        ],
      ),
    );
  }

  Widget _brakeDetailsColumn1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_brake_details_title,
            null,
            labelStyle: DASTextStyles.smallBold,
          ),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_brake_details_brake_ratio_front, 'ok'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_brake_details_brake_ratio_back, 'ok'),
          BreakLoadSlipDataRow(context.l10n.p_break_load_slip_brake_details_min_holding_force, '124'),
        ],
      ),
    );
  }

  Widget _brakeDetailsColumn2(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(right: 0.0),
      child: BreakLoadSlipBrakeDetailsTable(),
    );
  }
}
