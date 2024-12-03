import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

/// Represents a column in the [DASTable] with optional styling and width constraints.
/// Styles the heading and data cells if not explicitly overridden by the cells
///
/// Either [width] or [expanded] must be defined. There is no support for variable width.
@immutable
class DASTableColumn {
  const DASTableColumn({
    this.child,
    this.border,
    this.color,
    this.padding = const EdgeInsets.all(sbbDefaultSpacing * 0.5),
    this.expanded = false,
    this.width,
    this.hidden = false,
    this.alignment = Alignment.center,
  }) : assert((width != null && width > 0) || expanded);

  /// The content of the column header as a widget.
  final Widget? child;

  /// Border style for the heading and data cells
  final BoxBorder? border;

  /// The background color for the heading and data cells
  final Color? color;

  final EdgeInsets? padding;

  /// Whether the column should expand to fill available space.
  final bool expanded;

  /// The fixed width for the column. Must be specified if not expanded.
  final double? width;

  /// If provided, wraps child in Align widget. Can be overridden in [DASTableCell]
  final Alignment? alignment;

  /// Whether the column is visible or not.
  final bool hidden;

  get isVisible => !hidden;
}
