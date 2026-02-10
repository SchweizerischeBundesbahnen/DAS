import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:flutter/material.dart';

/// Represents a row in the [DASTable].
sealed class DASTableRow {
  const DASTableRow({
    required this.height,
    required this.key,
    required this.rowIndex,
    this.stickyLevel = .none,
    this.identifier,
    this.decoration,
  });

  final GlobalKey key;

  final double height;

  final StickyLevel stickyLevel;

  final String? identifier;

  final int rowIndex;

  final DASTableRowDecoration? decoration;
}

/// Represents a row in the [DASTable] containing cells.
@immutable
class DASTableCellRow extends DASTableRow {
  const DASTableCellRow({
    required this.cells,
    required super.height,
    required super.key,
    required super.rowIndex,
    super.decoration,
    this.onTap,
    this.onStartToEndDragReached,
    this.draggableBackgroundBuilder,
    super.stickyLevel,
    super.identifier,
    this.markAsDeleted = false,
  });

  final Map<int, DASTableCell> cells;

  final VoidCallback? onTap;

  /// The callback that is invoked if the user drags the row over a certain extent.
  final VoidCallback? onStartToEndDragReached;

  /// If [onStartToEndDragReached] is non null, this will be used to build the background of the row.
  ///
  /// The bool indicates whether the target was reached during drag movement.
  final Widget Function(BuildContext, bool)? draggableBackgroundBuilder;

  /// Whether to draw a strikethrough line and border over the row.
  final bool markAsDeleted;
}

class DASTableWidgetRow extends DASTableRow {
  const DASTableWidgetRow({
    required this.widget,
    required super.height,
    required super.key,
    required super.rowIndex,
    super.stickyLevel,
    super.identifier,
    super.decoration,
  });

  final Widget widget;
}
