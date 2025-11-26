import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHauledLoadDetails extends StatelessWidget {
  const BreakLoadSlipHauledLoadDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_title,
              null,
              labelStyle: DASTextStyles.smallBold,
            ),
            SizedBox(height: sbbDefaultSpacing * 0.5),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_total_vehicles, '14'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_total_vehicles_LL_K, '14'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_total_vehicles_D, '0'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_total_vehicles_disabled_brakes, '0'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_first_vehicle_evn, '21 85 2461 896-2'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_last_vehicle_evn, '12 34 5678 910-1'),
            BreakLoadSlipDataRow(context.l10n.p_break_load_slip_hauled_load_max_axle_load, '20'),
          ],
        ),
      ),
    );
  }
}
