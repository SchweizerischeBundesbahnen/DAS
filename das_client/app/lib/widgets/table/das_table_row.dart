import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

/// Interface for a class that builds [DASTableRow]
abstract class DASTableRowBuilder<T> {
  DASTableRowBuilder({
    required this.height,
    required this.data,
    required this.rowIndex,
    this.stickyLevel = StickyLevel.none,
    this.identifier,
    GlobalKey? key,
  }) : key = key ?? GlobalKey();

  DASTableRow build(BuildContext context);

  final double height;
  final StickyLevel stickyLevel;
  final T data;
  final int rowIndex;
  final String? identifier;
  final GlobalKey key;
}

/// Represents a row in the [DASTable] containing cells.
@immutable
class DASTableCellRow extends DASTableRow {
  const DASTableCellRow({
    required this.cells,
    required super.height,
    required super.key,
    required super.rowIndex,
    this.color,
    this.onTap,
    super.stickyLevel,
    super.identifier,
  });

  /// The background color for all cells of the row if not overridden by cell style.
  final Color? color;

  final Map<int, DASTableCell> cells;

  final VoidCallback? onTap;
}

class DASTableWidgetRow extends DASTableRow {
  const DASTableWidgetRow({
    required this.widget,
    required super.height,
    required super.key,
    required super.rowIndex,
    super.stickyLevel,
    super.identifier,
  });

  final Widget widget;
}

abstract class DASTableRow {
  const DASTableRow({
    required this.height,
    required this.key,
    required this.rowIndex,
    this.stickyLevel = StickyLevel.none,
    this.identifier,
  });

  final double height;

  final StickyLevel stickyLevel;

  final String? identifier;

  final int rowIndex;

  final GlobalKey key;
}
