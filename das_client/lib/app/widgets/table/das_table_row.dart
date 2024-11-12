import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

/// Interface for a class that builds [DASTableRow]
abstract class DASTableRowBuilder {
  const DASTableRowBuilder({this.height});

  DASTableRow build(BuildContext context);

  final double? height;
}

/// Represents a row in the [DASTable] containing cells.
@immutable
class DASTableRow {
  const DASTableRow({required this.cells, this.height, this.color});

  /// The fixed height for the row. If null, intrinsic height will be used.
  final double? height;

  /// The background color for all cells of the row if not overridden by cell style.
  final Color? color;

  final List<DASTableCell> cells;
}
