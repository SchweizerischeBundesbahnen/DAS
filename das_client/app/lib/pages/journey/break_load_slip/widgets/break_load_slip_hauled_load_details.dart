import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHauledLoadDetails extends StatelessWidget {
  const BreakLoadSlipHauledLoadDetails({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: KeyValueTable(
        rows: [
          KeyValueTableDataRow.title(
            context.l10n.p_break_load_slip_hauled_load_title,
            hasChange: _hasChange(),
          ),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_total_vehicles,
            formationRunChange.formationRun.vehiclesCount.toString(),
            hasChange: formationRunChange.hasChanged(.vehiclesCount),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_total_vehicles_LL_K,
            formationRunChange.formationRun.vehiclesWithBrakeDesignLlAndKCount.toString(),
            hasChange: formationRunChange.hasChanged(.vehiclesWithBrakeDesignLlAndKCount),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_total_vehicles_D,
            formationRunChange.formationRun.vehiclesWithBrakeDesignDCount.toString(),
            hasChange: formationRunChange.hasChanged(.vehiclesWithBrakeDesignDCount),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_total_vehicles_disabled_brakes,
            formationRunChange.formationRun.vehiclesWithDisabledBrakesCount.toString(),
            hasChange: formationRunChange.hasChanged(.vehiclesWithDisabledBrakesCount),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_first_vehicle_evn,
            _formationVehicleEvn(formationRunChange.formationRun.europeanVehicleNumberFirst),
            hasChange: formationRunChange.hasChanged(.europeanVehicleNumberFirst),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_last_vehicle_evn,
            _formationVehicleEvn(formationRunChange.formationRun.europeanVehicleNumberLast),
            hasChange: formationRunChange.hasChanged(.europeanVehicleNumberLast),
          ),
          KeyValueTableDataRow(
            context.l10n.p_break_load_slip_hauled_load_max_axle_load,
            (formationRunChange.formationRun.axleLoadMaxInKg / 1000).toString(),
            hasChange: formationRunChange.hasChanged(.axleLoadMaxInKg),
          ),
        ],
      ),
    );
  }

  bool _hasChange() {
    return formationRunChange.hasChanged(.vehiclesCount) ||
        formationRunChange.hasChanged(.vehiclesWithBrakeDesignLlAndKCount) ||
        formationRunChange.hasChanged(.vehiclesWithBrakeDesignDCount) ||
        formationRunChange.hasChanged(.vehiclesWithDisabledBrakesCount) ||
        formationRunChange.hasChanged(.europeanVehicleNumberFirst) ||
        formationRunChange.hasChanged(.europeanVehicleNumberLast) ||
        formationRunChange.hasChanged(.axleLoadMaxInKg);
  }

  String _formationVehicleEvn(String? evn) {
    if (evn == null || evn.length != 12) return evn ?? '';
    return '${evn.substring(0, 2)} ${evn.substring(2, 4)} ${evn.substring(4, 8)} ${evn.substring(8, 11)}-${evn.substring(11)}';
  }
}
