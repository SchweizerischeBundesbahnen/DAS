import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';

/// Represents a cell in the [DASTable] with optional styling and behavior.
///
/// If no styling is provided, it may be provided by [DASTableRow] or [DASTableTheme]
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

  const DASTableCell.empty() : this(child: const SizedBox.shrink());

  final BoxBorder? border;
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final Clip clipBehaviour;

  /// If provided, wraps child in Align widget. Can also be defined in [DASTableColumn]
  final Alignment? alignment;
}
