import 'package:flutter/material.dart';

/// Contains the theme data for styling the [DASTable].
@immutable
class DASTableThemeData {
  const DASTableThemeData({
    this.backgroundColor,
    this.dataRowColor,
    this.headingRowColor,
    this.tableBorder,
    this.headingRowBorder,
    this.headingTextStyle,
    this.dataTextStyle,
  });

  /// The background color of the table.
  final Color? backgroundColor;

  /// The background color of data rows.
  final Color? dataRowColor;

  /// The background color of the heading row.
  final Color? headingRowColor;

  /// The text style for data cells. Will be overridden if Text in cells provide own style.
  final TextStyle? dataTextStyle;

  /// The text style for heading cells. Will be overridden if Text in cells provide own style.
  final TextStyle? headingTextStyle;

  /// The border style for the heading row.
  final Border? headingRowBorder;

  /// The border style for the table.
  final TableBorder? tableBorder;

  DASTableThemeData copyWith({
    Color? dataRowColor,
    Color? headingRowColor,
    TableBorder? tableBorder,
    TextStyle? dataTextStyle,
    TextStyle? headingTextStyle,
    Border? headingRowBorder,
  }) {
    return DASTableThemeData(
      dataRowColor: dataRowColor ?? this.dataRowColor,
      headingRowColor: headingRowColor ?? this.headingRowColor,
      tableBorder: tableBorder ?? this.tableBorder,
      dataTextStyle: dataTextStyle ?? this.dataTextStyle,
      headingTextStyle: headingTextStyle ?? this.headingTextStyle,
      headingRowBorder: headingRowBorder ?? this.headingRowBorder,
    );
  }

  static DASTableThemeData lerp(DASTableThemeData a, DASTableThemeData b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return DASTableThemeData(
      dataRowColor: Color.lerp(a.dataRowColor, b.dataRowColor, t),
      headingRowColor: Color.lerp(a.headingRowColor, b.headingRowColor, t),
      tableBorder: TableBorder.lerp(a.tableBorder, b.tableBorder, t),
      headingTextStyle: TextStyle.lerp(a.headingTextStyle, b.headingTextStyle, t),
      dataTextStyle: TextStyle.lerp(a.dataTextStyle, b.dataTextStyle, t),
      headingRowBorder: Border.lerp(a.headingRowBorder, b.headingRowBorder, t),
    );
  }

  @override
  int get hashCode => Object.hash(
    dataRowColor,
    headingRowColor,
    tableBorder,
    dataTextStyle,
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
        other.dataRowColor == dataRowColor &&
        other.headingRowColor == headingRowColor &&
        other.headingTextStyle == headingTextStyle &&
        other.dataTextStyle == dataTextStyle &&
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
