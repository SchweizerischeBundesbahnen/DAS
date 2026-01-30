import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef TextFunction = Text Function(String);

class BreakLoadSlipTrainDetailsTable extends StatelessWidget {
  static const double _rowHeight = 32.0;

  const BreakLoadSlipTrainDetailsTable({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      dataRowMinHeight: _rowHeight,
      dataRowMaxHeight: _rowHeight,
      headingRowHeight: _rowHeight,
      columnSpacing: SBBSpacing.medium,
      horizontalMargin: SBBSpacing.xSmall,
      dividerThickness: 1,
      headingTextStyle: sbbTextStyle.lightStyle.small,
      dataTextStyle: sbbTextStyle.romanStyle.small,
      columns: [
        DataColumn(
          label: Text(''),
        ),
        DataColumn(
          label: Align(
            alignment: Alignment.center,
            child: Text(context.l10n.p_break_load_slip_train_data_table_header_traction),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Align(
            alignment: Alignment.center,
            child: Text(context.l10n.p_break_load_slip_train_data_table_header_hauled_load),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Align(
            alignment: Alignment.center,
            child: Text(context.l10n.p_break_load_slip_train_data_table_header_formation),
          ),
          numeric: true,
        ),
      ],
      rows: [
        _buildDataRow(
          context.l10n.p_break_load_slip_train_data_table_vmax,
          formationRunChange.formationRun.tractionMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.tractionMaxSpeedInKmh),
          formationRunChange.formationRun.hauledLoadMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.hauledLoadMaxSpeedInKmh),
          formationRunChange.formationRun.formationMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.formationMaxSpeedInKmh),
        ),
        _buildDataRow(
          context.l10n.p_break_load_slip_train_data_table_length,
          (formationRunChange.formationRun.tractionLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.tractionLengthInCm),
          (formationRunChange.formationRun.hauledLoadLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.hauledLoadLengthInCm),
          (formationRunChange.formationRun.formationLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.formationLengthInCm),
        ),
        _buildDataRow(
          context.l10n.p_break_load_slip_train_data_table_weight,
          formationRunChange.formationRun.tractionWeightInT.toString(),
          formationRunChange.hasChanged(.tractionWeightInT),
          formationRunChange.formationRun.hauledLoadWeightInT.toString(),
          formationRunChange.hasChanged(.hauledLoadWeightInT),
          formationRunChange.formationRun.formationWeightInT.toString(),
          formationRunChange.hasChanged(.formationWeightInT),
        ),
        _buildDataRow(
          context.l10n.p_break_load_slip_train_data_table_braked_weight,
          formationRunChange.formationRun.tractionBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.tractionBrakedWeightInT),
          formationRunChange.formationRun.hauledLoadBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.hauledLoadBrakedWeightInT),
          formationRunChange.formationRun.formationBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.formationBrakedWeightInT),
        ),
        _buildDataRow(
          context.l10n.p_break_load_slip_brake_details_holding_force,
          (formationRunChange.formationRun.tractionHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.tractionHoldingForceInHectoNewton),
          (formationRunChange.formationRun.hauledLoadHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.hauledLoadHoldingForceInHectoNewton),
          (formationRunChange.formationRun.formationHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.formationHoldingForceInHectoNewton),
        ),
      ],
    );
  }

  DataRow _buildDataRow(
    String label,
    String? c1,
    bool hasChangeC1,
    String? c2,
    bool hasChangeC2,
    String? c3,
    bool hasChangeC3,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(label, style: sbbTextStyle.romanStyle.small),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: _wrappedText(c1, hasChangeC1),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: _wrappedText(c2, hasChangeC2),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: _wrappedText(c3, hasChangeC3),
          ),
        ),
      ],
    );
  }

  Widget _wrappedText(String? text, bool hasChange) {
    final finalStyle = hasChange ? sbbTextStyle.boldStyle.small : sbbTextStyle.romanStyle.small;
    final textWidget = Text(text ?? '', style: finalStyle);
    return hasChange
        ? DotIndicator(
            offset: Offset(0, -SBBSpacing.small),
            child: textWidget,
          )
        : textWidget;
  }
}
