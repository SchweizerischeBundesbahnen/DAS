import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Represents a column in the [DASTable] with optional styling and width constraints.
/// Styles the heading and data cells if not explicitly overridden by the cells
///
/// Either [width] or [expanded] must be defined. There is no support for variable width.
@immutable
class DASTableColumn {
  const DASTableColumn({
    required this.id,
    this.child,
    this.border,
    this.color,
    this.padding = const EdgeInsets.all(sbbDefaultSpacing * 0.5),
    this.expanded = false,
    this.width,
    this.alignment = Alignment.center,
    this.onTap,
    this.headerKey,
  }) : assert(width != null || expanded);

  /// The unique identifier for the column.
  final int id;

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

  /// Callback for tap events on the column header.
  final GestureTapCallback? onTap;

  /// Key for the header cell
  final Key? headerKey;
}
