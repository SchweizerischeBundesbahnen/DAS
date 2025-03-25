import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

/// Interface for a class that builds [DASTableCellRow]
abstract class DASTableRowBuilder<T> {
  const DASTableRowBuilder({required this.height, required this.data, this.isSticky = false});

  DASTableRow build(BuildContext context);

  final double height;
  final bool isSticky;
  final T data;
}

/// Represents a row in the [DASTable] containing cells.
@immutable
class DASTableCellRow extends DASTableRow {
  const DASTableCellRow({required this.cells, required super.height, this.color, this.onTap, super.isSticky});

  /// The background color for all cells of the row if not overridden by cell style.
  final Color? color;

  final Map<int, DASTableCell> cells;

  final VoidCallback? onTap;
}

class DASTableWidgetRow extends DASTableRow {
  const DASTableWidgetRow({required this.widget, required super.height, super.isSticky});

  final Widget widget;
}

abstract class DASTableRow {
  const DASTableRow({required this.height, this.isSticky = false});

  final double height;

  final bool isSticky;
}
