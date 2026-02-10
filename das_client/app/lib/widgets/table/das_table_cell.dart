import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:app/widgets/table/das_table_theme.dart';
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
    this.decoration,
    this.padding,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  });

  const DASTableCell.empty({
    VoidCallback? onTap,
    EdgeInsets? padding,
    DASTableCellDecoration? decoration,
    Clip clipBehaviour = Clip.hardEdge,
  }) : this(child: emptyBuilder, onTap: onTap, decoration: decoration);

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
    DASTableCellDecoration? decoration,
    EdgeInsets? padding,
    Alignment? alignment,
    Clip? clipBehavior,
  }) {
    return DASTableCell(
      child: child ?? this.child,
      onTap: onTap ?? this.onTap,
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
    this.color,
    this.border,
    this.borderRadius,
  });

  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;

  DASTableCellDecoration copyWith({
    Border? border,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return DASTableCellDecoration(
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      color: color ?? this.color,
    );
  }
}
