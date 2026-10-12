import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Data class for holding the decoration fields of a [DASTableRow].
@immutable
class DASTableRowDecoration {
  const DASTableRowDecoration({
    this.chevronAnimationColor,
    this.border,
  });

  /// Optional background color that overrides the background color of the row style while the Chevron animation
  /// is running.
  final Color? chevronAnimationColor;

  /// The sides of the border of this column.
  ///
  /// The sides will be overridden by more specific cell border sides.
  ///
  /// The left and right border will only be applied to the left and right cell of the row respectively.
  final Border? border;

  DASTableRowDecoration copyWith({
    Border? border,
    Color? chevronAnimationColor,
  }) {
    return DASTableRowDecoration(
      border: border ?? this.border,
      chevronAnimationColor: chevronAnimationColor ?? this.chevronAnimationColor,
    );
  }
}
