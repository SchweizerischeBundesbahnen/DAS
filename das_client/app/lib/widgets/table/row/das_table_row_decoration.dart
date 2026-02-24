import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Data class for holding the decoration fields of a [DASTableRow].
@immutable
class DASTableRowDecoration {
  const DASTableRowDecoration({
    this.color,
    this.border,
  });

  /// The background color of this row. This is overridden by specific cell background colors.
  final Color? color;

  /// The sides of the border of this column.
  ///
  /// The sides will be overridden by more specific cell border sides.
  ///
  /// The left and right border will only be applied to the left and right cell of the row respectively.
  final Border? border;

  DASTableRowDecoration copyWith({
    Border? border,
    Color? color,
  }) {
    return DASTableRowDecoration(
      border: border ?? this.border,
      color: color ?? this.color,
    );
  }
}
