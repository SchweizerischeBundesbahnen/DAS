import 'package:app/widgets/table/das_table_cell.dart';
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

/// Data class for holding the decoration fields of a [DASTableRow].
@immutable
class DASTableColumnDecoration {
  const DASTableColumnDecoration({
    this.color,
    this.border,
    this.borderRadius,
  });

  /// The background color of this column. This is overridden by specific row background colors.
  final Color? color;

  /// The radius of the border of this column.
  ///
  /// The radii will be overridden by more specific row border radii.
  ///
  /// The radii will only be applied to the edge cells (top and bottom) of the column.
  final BorderRadius? borderRadius;

  /// The sides of the border of this column.
  ///
  /// The sides will be overridden by more specific row border sides.
  ///
  /// The top and bottom border will only be applied to the first and last row of the table respectively.
  final Border? border;

  DASTableColumnDecoration copyWith({
    Border? border,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return DASTableColumnDecoration(
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      color: color ?? this.color,
    );
  }
}
