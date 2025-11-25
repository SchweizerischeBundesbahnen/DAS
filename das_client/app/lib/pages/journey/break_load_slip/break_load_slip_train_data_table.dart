import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipTrainDataTable extends StatelessWidget {
  const BreakLoadSlipTrainDataTable({super.key});

  final columnWidths = const {
    0: FlexColumnWidth(3),
    1: FlexColumnWidth(2),
    2: FlexColumnWidth(2),
    3: FlexColumnWidth(2),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        Table(
          columnWidths: columnWidths,
          children: [
            TableRow(
              children: [
                Container(),
                Center(child: _tableTitleText(context.l10n.p_break_load_slip_train_data_table_header_traction)),
                Center(child: _tableTitleText(context.l10n.p_break_load_slip_train_data_table_header_hauled_load)),
                Center(child: _tableTitleText(context.l10n.p_break_load_slip_train_data_table_header_formation)),
              ],
            ),
          ],
        ),
        const SizedBox(height: sbbDefaultSpacing * 0.25),
        _tableDivider(height: 2),
        _tableRow(context.l10n.p_break_load_slip_train_data_table_vmax, '160', '100', '100'),
        _tableDivider(),
        _tableRow(context.l10n.p_break_load_slip_train_data_table_length, '19', '298', '317'),
        _tableDivider(),
        _tableRow(context.l10n.p_break_load_slip_train_data_table_weight, '90', '787', '877'),
        _tableDivider(),
        _tableRow(context.l10n.p_break_load_slip_train_data_table_braked_weight, '58', '682', '740'),
      ],
    );
  }

  Widget _tableRow(String label, String c1, String c2, String c3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.25).copyWith(left: sbbDefaultSpacing * 0.5),
      child: Table(
        columnWidths: columnWidths,
        children: [
          TableRow(
            children: [
              _tableText(label),
              Center(child: _tableText(c1)),
              Center(child: _tableText(c2)),
              Center(child: _tableText(c3)),
            ],
          ),
        ],
      ),
    );
  }

  Text _tableTitleText(String text) {
    return Text(
      text,
      style: DASTextStyles.smallLight,
    );
  }

  Text _tableText(String text) {
    return Text(
      text,
      style: DASTextStyles.smallRoman,
    );
  }

  Widget _tableDivider({double height = 1}) {
    return Container(
      height: height,
      color: SBBColors.cloud,
    );
  }
}
