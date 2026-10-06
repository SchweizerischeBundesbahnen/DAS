import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:flutter/material.dart';

/// Holds the colors and text style of a data cell in the [DASTable].
///
/// Can be defined on [DASTableThemeData], [DASTableColumn], [DASTableCellRow] and [DASTableCell].
/// The [DASTable] resolves these levels from the least to the most specific one, where the more specific
/// level always wins. Within a level, the [foregroundColor] overrides the color of the [textStyle].
///
/// The resolved style is applied to the cell content as [DefaultTextStyle] and [IconTheme].
/// Content that can read neither, like svg color filters and custom painters, can access it with [of]:
///
/// ```dart
/// final color = DASTableCellStyle.of(context)?.foregroundColor ?? ThemeUtil.getIconColor(context);
/// ```
@immutable
class DASTableCellStyle {
  const DASTableCellStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  /// The background color of the cell.
  final Color? backgroundColor;

  /// The color of the content of the cell, e.g. text, icons and lines.
  final Color? foregroundColor;

  /// The text style of the cell. Will be overridden if Text in cells provide own style.
  final TextStyle? textStyle;

  /// Retrieves the resolved style of the surrounding [DASTableCell].
  static DASTableCellStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DASTableCellStyleScope>()?.style;
  }

  /// Returns a new style where the non null fields of [other] override the fields of this style.
  ///
  /// The text styles are merged. The foreground color of [other] is applied as text color.
  DASTableCellStyle merge(DASTableCellStyle? other) {
    if (other == null) return this;

    final foreground = other.foregroundColor ?? other.textStyle?.color ?? foregroundColor;
    TextStyle? mergedTextStyle = textStyle?.merge(other.textStyle) ?? other.textStyle;
    if (foreground != null) mergedTextStyle = (mergedTextStyle ?? TextStyle()).copyWith(color: foreground);

    return DASTableCellStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: foreground,
      textStyle: mergedTextStyle,
    );
  }

  DASTableCellStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? textStyle,
  }) {
    return DASTableCellStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  static DASTableCellStyle? lerp(DASTableCellStyle? a, DASTableCellStyle? b, double t) {
    if (identical(a, b)) return a;
    return DASTableCellStyle(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      foregroundColor: Color.lerp(a?.foregroundColor, b?.foregroundColor, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
    );
  }

  /// Provides this style to [child] as [DefaultTextStyle], [IconTheme] and for lookups with [of].
  Widget apply({required Widget child}) {
    Widget result = child;
    if (foregroundColor != null) {
      result = IconTheme.merge(
        data: IconThemeData(color: foregroundColor),
        child: result,
      );
    }
    if (textStyle != null) result = DefaultTextStyle.merge(style: textStyle, child: result);
    return _DASTableCellStyleScope(style: this, child: result);
  }

  @override
  int get hashCode => Object.hash(backgroundColor, foregroundColor, textStyle);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DASTableCellStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.textStyle == textStyle;
  }
}

class _DASTableCellStyleScope extends InheritedWidget {
  const _DASTableCellStyleScope({required this.style, required super.child});

  final DASTableCellStyle style;

  @override
  bool updateShouldNotify(_DASTableCellStyleScope oldWidget) => style != oldWidget.style;
}
