import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Data class for holding the decoration fields of a [DASTableRow].
@immutable
class DASTableRowDecoration {
  const DASTableRowDecoration({
    this.color,
    this.border,
    this.borderRadius,
  });

  /// The background color of this row. This is overridden by specific cell background colors.
  final Color? color;

  /// The radius of the border of this row.
  ///
  /// The radii will be overridden by more specific cell border radii.
  ///
  /// The radii will only be applied to the edge cells of the row.
  final BorderRadius? borderRadius;

  /// The sides of the border of this column.
  ///
  /// The sides will be overridden by more specific cell border sides.
  ///
  /// The left and right border will only be applied to the left and right cell of the row respectively.
  final Border? border;

  DASTableRowDecoration copyWith({
    Border? border,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return DASTableRowDecoration(
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      color: color ?? this.color,
    );
  }
}
