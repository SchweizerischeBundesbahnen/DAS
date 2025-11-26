import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef TextFunction = Text Function(String);

class BreakLoadSlipBrakeDetailsTable extends StatelessWidget {
  const BreakLoadSlipBrakeDetailsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tableRow(
          '',
          context.l10n.p_break_load_slip_train_data_table_header_traction,
          context.l10n.p_break_load_slip_train_data_table_header_hauled_load,
          context.l10n.p_break_load_slip_train_data_table_header_formation,
          style: DASTextStyles.smallLight,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: sbbDefaultSpacing * 0.25),
        _tableDivider(height: 2),
        _tableRow(context.l10n.p_break_load_slip_brake_details_holding_force, '56', '421', '477'),
        _tableDivider(),
      ],
    );
  }

  Widget _tableRow(
    String label,
    String c1,
    String c2,
    String c3, {
    TextStyle style = DASTextStyles.smallRoman,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.25).copyWith(left: sbbDefaultSpacing * 0.5),
      child: Row(
        children: [
          Expanded(flex: 3, child: _tableText(label, style)),
          Expanded(flex: 2, child: Center(child: _tableText(c1, style))),
          Expanded(flex: 2, child: Center(child: _tableText(c2, style))),
          Expanded(flex: 2, child: Center(child: _tableText(c3, style))),
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

  Widget _tableDivider({double height = 1}) {
    return Container(
      height: height,
      color: SBBColors.cloud,
    );
  }
}
