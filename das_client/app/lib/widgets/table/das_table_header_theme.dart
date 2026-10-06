import 'package:flutter/material.dart';

/// Contains the theme data for styling the header row of the [DASTable].
@immutable
class DASTableHeaderThemeData {
  const DASTableHeaderThemeData({
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.border,
  });

  /// The background color of the header cells.
  final Color? backgroundColor;

  /// The color of the content of the header cells. Overrides the color of the [textStyle].
  final Color? foregroundColor;

  /// The text style for header cells. Will be overridden if Text in cells provide own style.
  final TextStyle? textStyle;

  /// The border of the header cells. Overrides the border of the column decoration.
  final Border? border;

  DASTableHeaderThemeData copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? textStyle,
    Border? border,
  }) {
    return DASTableHeaderThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
    );
  }

  static DASTableHeaderThemeData lerp(DASTableHeaderThemeData a, DASTableHeaderThemeData b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return DASTableHeaderThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      border: Border.lerp(a.border, b.border, t),
    );
  }

  @override
  int get hashCode => Object.hash(backgroundColor, foregroundColor, textStyle, border);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DASTableHeaderThemeData &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.textStyle == textStyle &&
        other.border == border;
  }
}

/// A widget that provides the header theme data for the [DASTable] and its descendants.
class DASTableHeaderTheme extends InheritedWidget {
  const DASTableHeaderTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The properties used for all descendant [DASTableHeaderTheme] widgets.
  final DASTableHeaderThemeData data;

  /// Retrieves the nearest [DASTableHeaderTheme] instance from the build context.
  static DASTableHeaderTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DASTableHeaderTheme>();
  }

  @override
  bool updateShouldNotify(DASTableHeaderTheme oldWidget) => data != oldWidget.data;
}
