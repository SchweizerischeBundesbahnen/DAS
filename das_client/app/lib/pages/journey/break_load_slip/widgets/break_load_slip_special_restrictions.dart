import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipSpecialRestrictions extends StatelessWidget {
  const BreakLoadSlipSpecialRestrictions({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_special_restrictions_title,
              null,
              labelStyle: DASTextStyles.smallBold,
            ),
            SizedBox(height: sbbDefaultSpacing * 0.5),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_special_restrictions_sim_train,
              formationRun.simTrain ? context.l10n.c_yes : context.l10n.c_no,
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_special_restrictions_car_carrier,
              formationRun.carCarrierVehicle ? context.l10n.c_yes : context.l10n.c_no,
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_special_restrictions_dangerous_goods,
              formationRun.dangerousGoods ? context.l10n.c_yes : context.l10n.c_no,
              valueStyle: formationRun.dangerousGoods ? DASTextStyles.smallBold : null,
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_special_restrictions_route_class,
              formationRun.routeClass,
            ),
            BreakLoadSlipDataRow('', ''),
            BreakLoadSlipDataRow('', ''),
            BreakLoadSlipDataRow('', ''),
          ],
        ),
      ),
    );
  }
}
