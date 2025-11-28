import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef TextFunction = Text Function(String);

class BreakLoadSlipTrainDetailsTable extends StatelessWidget {
  const BreakLoadSlipTrainDetailsTable({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tableRow(
          null,
          context.l10n.p_break_load_slip_train_data_table_header_traction,
          context.l10n.p_break_load_slip_train_data_table_header_hauled_load,
          context.l10n.p_break_load_slip_train_data_table_header_formation,
          style: DASTextStyles.smallLight,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: sbbDefaultSpacing * 0.25),
        _tableDivider(context, height: 2),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_vmax,
          formationRun.tractionMaxSpeedInKmh?.toString(),
          formationRun.hauledLoadMaxSpeedInKmh?.toString(),
          formationRun.formationMaxSpeedInKmh?.toString(),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_length,
          (formationRun.tractionLengthInCm / 100).toString(),
          (formationRun.hauledLoadLengthInCm / 100).toString(),
          (formationRun.formationLengthInCm / 100).toString(),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_weight,
          formationRun.tractionWeightInT.toString(),
          formationRun.hauledLoadWeightInT.toString(),
          formationRun.formationWeightInT.toString(),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_braked_weight,
          formationRun.tractionBrakedWeightInT.toString(),
          formationRun.hauledLoadBrakedWeightInT.toString(),
          formationRun.formationBrakedWeightInT.toString(),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_brake_details_holding_force,
          (formationRun.tractionHoldingForceInHectoNewton / 10).toString(),
          (formationRun.hauledLoadHoldingForceInHectoNewton / 10).toString(),
          (formationRun.formationHoldingForceInHectoNewton / 10).toString(),
        ),
      ],
    );
  }

  Widget _tableRow(
    String? label,
    String? c1,
    String? c2,
    String? c3, {
    TextStyle style = DASTextStyles.smallRoman,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.25).copyWith(left: sbbDefaultSpacing * 0.5),
      child: Row(
        children: [
          Expanded(flex: 3, child: _tableText(label ?? '', style)),
          Expanded(flex: 2, child: Center(child: _tableText(c1 ?? '', style))),
          Expanded(flex: 2, child: Center(child: _tableText(c2 ?? '', style))),
          Expanded(flex: 2, child: Center(child: _tableText(c3 ?? '', style))),
        ],
      ),
    );
  }

  Text _tableText(String text, TextStyle style) {
    return Text(
      text,
      style: style,
    );
  }

  Widget _tableDivider(BuildContext context, {double height = 1}) {
    return Container(
      height: height,
      color: ThemeUtil.isDarkMode(context) ? SBBColors.iron : SBBColors.cloud,
    );
  }
}
