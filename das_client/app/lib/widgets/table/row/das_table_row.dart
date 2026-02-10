import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

/// Interface for a class that builds [DASTableRow]
abstract class DASTableRowBuilder<T> {
  static final Map<int, GlobalKey> _tableRowKeys = {};

  static GlobalKey _getRowKey(int identifier) {
    if (!_tableRowKeys.containsKey(identifier)) {
      _tableRowKeys[identifier] = GlobalKey();
    }
    return _tableRowKeys[identifier]!;
  }

  static void clearRowKeys() => _tableRowKeys.clear();

  DASTableRowBuilder({
    required this.height,
    required this.data,
    required this.rowIndex,
    this.stickyLevel = .none,
    this.identifier,
    GlobalKey? key,
  }) : key = key ?? _getRowKey(data.hashCode ^ rowIndex);

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
    this.onStartToEndDragReached,
    this.draggableBackgroundBuilder,
    super.stickyLevel,
    super.identifier,
    this.markAsDeleted = false,
  });

  /// The background color for all cells of the row if not overridden by cell style.
  final Color? color;

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
  });

  final Widget widget;
}

abstract class DASTableRow {
  const DASTableRow({
    required this.height,
    required this.key,
    required this.rowIndex,
    this.stickyLevel = .none,
    this.identifier,
  });

  final double height;

  final StickyLevel stickyLevel;

  final String? identifier;

  final int rowIndex;

  final GlobalKey key;
}
