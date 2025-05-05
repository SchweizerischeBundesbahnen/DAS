import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';

/// Represents a cell in the [DASTable] with optional styling and behavior.
///
/// If no styling is provided, it may be provided by [DASTableCellRow] or [DASTableTheme]
@immutable
class DASTableCell {
  const DASTableCell({
    required this.child,
    this.onTap,
    this.border,
    this.color,
    this.padding,
    this.alignment,
    this.clipBehaviour = Clip.hardEdge,
  });

  const DASTableCell.empty({Color? color}) : this(child: const SizedBox.shrink(), color: color);

  final BoxBorder? border;
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final Clip clipBehaviour;

  /// If provided, wraps child in Align widget. Can also be defined in [DASTableColumn]
  final Alignment? alignment;
}
