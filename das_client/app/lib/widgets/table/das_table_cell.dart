import 'package:app/widgets/table/das_table_cell_style.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:flutter/material.dart';

/// Represents a cell in the [DASTable] with optional styling and behavior.
///
/// If no styling is provided, it may be provided by [DASTableCellRow] or [DASTableTheme]
@immutable
class DASTableCell {
  static const emptyCellKey = Key('DASTableCellEmptyKey');

  static const Widget emptyBuilder = SizedBox.shrink(key: emptyCellKey);

  const DASTableCell({
    required this.child,
    this.onTap,
    this.style,
    this.decoration,
    this.padding,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  });

  const DASTableCell.empty({
    VoidCallback? onTap,
    EdgeInsets? padding,
    DASTableCellStyle? style,
    DASTableCellDecoration? decoration,
    Clip clipBehaviour = Clip.hardEdge,
  }) : this(child: emptyBuilder, onTap: onTap, style: style, decoration: decoration);

  /// The most specific style of this cell. Overrides the styles of row, column and theme.
  final DASTableCellStyle? style;

  final DASTableCellDecoration? decoration;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Clip clipBehavior;

  /// If provided, wraps child in Align widget. Can also be defined in [DASTableColumn]
  final Alignment? alignment;

  DASTableCell copyWith({
    Widget? child,
    VoidCallback? onTap,
    DASTableCellStyle? style,
    DASTableCellDecoration? decoration,
    EdgeInsets? padding,
    Alignment? alignment,
    Clip? clipBehavior,
  }) {
    return DASTableCell(
      child: child ?? this.child,
      onTap: onTap ?? this.onTap,
      style: style ?? this.style,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}

/// Data class for holding the decoration fields of a [DASTableCell].
@immutable
class DASTableCellDecoration {
  const DASTableCellDecoration({
    this.border,
  });

  final Border? border;

  DASTableCellDecoration copyWith({
    Border? border,
  }) {
    return DASTableCellDecoration(
      border: border ?? this.border,
    );
  }
}
