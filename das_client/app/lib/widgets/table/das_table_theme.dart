import 'package:app/widgets/table/das_table_cell_style.dart';
import 'package:flutter/material.dart';

/// Contains the theme data for styling the [DASTable].
@immutable
class DASTableThemeData {
  const DASTableThemeData({
    this.backgroundColor,
    this.dataCellStyle,
    this.headingRowColor,
    this.tableBorder,
    this.headingRowBorder,
    this.headingTextStyle,
  });

  /// The background color of the table.
  final Color? backgroundColor;

  /// The least specific style of the data cells.
  ///
  /// Will be overridden by the styles of columns, rows and cells.
  final DASTableCellStyle? dataCellStyle;

  /// The background color of the heading row.
  final Color? headingRowColor;

  /// The text style for heading cells. Will be overridden if Text in cells provide own style.
  final TextStyle? headingTextStyle;

  /// The border style for the heading row.
  final Border? headingRowBorder;

  /// The border style for the table.
  ///
  /// The resulting Border will be tried to merge with the column / cell border.
  /// If that is not possible, the column / cell border is used.
  final TableBorder? tableBorder;

  DASTableThemeData copyWith({
    Color? backgroundColor,
    DASTableCellStyle? dataCellStyle,
    Color? headingRowColor,
    TableBorder? tableBorder,
    TextStyle? headingTextStyle,
    Border? headingRowBorder,
  }) {
    return DASTableThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dataCellStyle: dataCellStyle ?? this.dataCellStyle,
      headingRowColor: headingRowColor ?? this.headingRowColor,
      tableBorder: tableBorder ?? this.tableBorder,
      headingTextStyle: headingTextStyle ?? this.headingTextStyle,
      headingRowBorder: headingRowBorder ?? this.headingRowBorder,
    );
  }

  static DASTableThemeData lerp(DASTableThemeData a, DASTableThemeData b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return DASTableThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      dataCellStyle: DASTableCellStyle.lerp(a.dataCellStyle, b.dataCellStyle, t),
      headingRowColor: Color.lerp(a.headingRowColor, b.headingRowColor, t),
      tableBorder: TableBorder.lerp(a.tableBorder, b.tableBorder, t),
      headingTextStyle: TextStyle.lerp(a.headingTextStyle, b.headingTextStyle, t),
      headingRowBorder: Border.lerp(a.headingRowBorder, b.headingRowBorder, t),
    );
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    dataCellStyle,
    headingRowColor,
    tableBorder,
    headingTextStyle,
    headingRowBorder,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DASTableThemeData &&
        other.backgroundColor == backgroundColor &&
        other.dataCellStyle == dataCellStyle &&
        other.headingRowColor == headingRowColor &&
        other.headingTextStyle == headingTextStyle &&
        other.headingRowBorder == headingRowBorder &&
        other.tableBorder == tableBorder;
  }
}

/// A widget that provides the theme data for the [DASTable] and its descendants.
class DASTableTheme extends InheritedWidget {
  const DASTableTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The properties used for all descendant [DASTableTheme] widgets.
  final DASTableThemeData data;

  /// Retrieves the nearest [DASTableTheme] instance from the build context.
  static DASTableTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DASTableTheme>();
  }

  @override
  bool updateShouldNotify(DASTableTheme oldWidget) => data != oldWidget.data;
}
