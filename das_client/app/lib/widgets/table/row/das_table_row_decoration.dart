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

  /// The borderRadius of the border of this row. This is merged or overridden by specific cell border radii.
  ///
  /// The topLeft / bottomLeft and topRight / bottomRight will only be applied to the left / right cell respectively.
  final BorderRadius? borderRadius;

  /// The sides of the border of this row. This is merged or overridden by specific cell borders.
  ///
  /// The right and left border will only be applied to the first and last cell of the row respectively.
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
