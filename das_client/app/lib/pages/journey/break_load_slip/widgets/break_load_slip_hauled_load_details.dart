import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHauledLoadDetails extends StatelessWidget {
  const BreakLoadSlipHauledLoadDetails({required this.formationRun, super.key});

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
              context.l10n.p_break_load_slip_hauled_load_title,
              null,
              labelStyle: DASTextStyles.smallBold,
            ),
            SizedBox(height: sbbDefaultSpacing * 0.5),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_total_vehicles,
              formationRun.vehiclesCount.toString(),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_total_vehicles_LL_K,
              formationRun.vehiclesWithBrakeDesignLlAndKCount.toString(),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_total_vehicles_D,
              formationRun.vehiclesWithBrakeDesignDCount.toString(),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_total_vehicles_disabled_brakes,
              formationRun.vehiclesWithDisabledBrakesCount.toString(),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_first_vehicle_evn,
              _formationVehicleEvn(formationRun.europeanVehicleNumberFirst),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_last_vehicle_evn,
              _formationVehicleEvn(formationRun.europeanVehicleNumberLast),
            ),
            BreakLoadSlipDataRow(
              context.l10n.p_break_load_slip_hauled_load_max_axle_load,
              (formationRun.axleLoadMaxInKg / 1000).toString(),
            ),
          ],
        ),
      ),
    );
  }

  String _formationVehicleEvn(String? evn) {
    if (evn == null || evn.length != 12) return evn ?? '';
    return '${evn.substring(0, 2)} ${evn.substring(2, 4)} ${evn.substring(4, 8)} ${evn.substring(8, 11)}-${evn.substring(11)}';
  }
}
