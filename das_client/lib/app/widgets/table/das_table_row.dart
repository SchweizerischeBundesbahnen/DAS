import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:flutter/foundation.dart';

/// Represents a row in the [DASTable] containing cells.
@immutable
class DASTableRow {
  const DASTableRow({this.height, required this.cells});

  /// The fixed height for the row. If null, intrinsic height will be used.
  final double? height;

  final List<DASTableCell> cells;
}
