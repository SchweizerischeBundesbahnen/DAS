import 'package:data_table_2/data_table_2.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

// TODO: data_table_2 doesn't support expanded columns and line will also be difficult to implement
// TODO: How to implement line, does it need to be fluent or jumping?
// TODO: If line is within rows and the border is over 0.5 width, there is a visible gap.
// TODO: Clipping is only for outside table and not for individual rows
// TODO: Individual vertical dividers need to be manually created for example with a divider
// TODO: Individual row heights or dynamic row height not supported -> KILLER!
class FahrbildTable extends StatelessWidget {
  const FahrbildTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 8.0,
      horizontalMargin: 8.0,
      headingRowHeight: 40.0,
      dataRowHeight: 64.0, // only set for all rows!
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        color: SBBColors.white,
      ),
      bottomMargin: sbbDefaultSpacing * 2,
      border: const TableBorder(
        bottom: BorderSide(width: 1.0, color: SBBColors.cloud),
        horizontalInside: BorderSide(width: 0.3, color: SBBColors.cloud),
      ),
      columns: columns,
      rows: rows,
    );
  }
}
