import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_cell_style.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Represents a column in the [DASTable] with optional styling and width constraints.
/// Styles the heading and data cells if not explicitly overridden by the cells
///
/// Either [width] or [expanded] must be defined. There is no support for variable width.
@immutable
class DASTableColumn {
  const DASTableColumn({
    this.id,
    this.child,
    this.style,
    this.decoration,
    this.padding = const .all(SBBSpacing.xSmall),
    this.expanded = false,
    this.width,
    this.alignment = .center,
    this.onTap,
    this.headerKey,
  }) : assert(width != null || expanded);

  /// The unique identifier for the column.
  final int? id;

  /// The content of the column header as a widget.
  final Widget? child;

  /// The style of the data cells in this column.
  ///
  /// Overrides the [DASTableThemeData.dataCellStyle] and is overridden by row and cell styles.
  /// Does not apply to the header cell.
  final DASTableCellStyle? style;

  /// The decoration for the column.
  ///
  /// This will merge / override the [DASTableTheme] decorations, but will be overriden / merged by
  /// row decoration.
  ///
  /// The top and bottom specific properties will only be applied to first and last row and to the sticky header.
  final DASTableColumnDecoration? decoration;

  final EdgeInsets? padding;

  /// Whether the column should expand to fill available space.
  final bool expanded;

  /// The fixed width for the column. Must be specified if not expanded.
  final double? width;

  /// If provided, wraps child in Align widget. Can be overridden in [DASTableCell]
  final Alignment? alignment;

  /// Callback for tap events on the column header.
  final GestureTapCallback? onTap;

  /// Key for the header cell
  final Key? headerKey;
}

/// Represents the decoration of a column of the [DASTable].
@immutable
class DASTableColumnDecoration {
  const DASTableColumnDecoration({
    this.border,
  });

  /// The sides of the border of this column.
  ///
  /// The sides will be overridden by more specific row border sides.
  ///
  /// The top and bottom border will only be applied to the first and last row of the table respectively.
  final Border? border;

  DASTableColumnDecoration copyWith({
    Border? border,
  }) {
    return DASTableColumnDecoration(
      border: border ?? this.border,
    );
  }
}

extension DASTableColumnIterableX on Iterable<DASTableColumn> {
  /// returns the left offset of the column with the given [DASTableColumn.id]
  double leftOffsetTo({required int columnId}) {
    if (none((column) => column.id == columnId)) return 0;

    final columnsOnLeft = takeWhile(
      (column) => column.id == null || column.id != columnId,
    ).map((column) => column.width).nonNulls;

    if (columnsOnLeft.isEmpty) return 0;

    return columnsOnLeft.reduce((a, b) => a + b);
  }
}
