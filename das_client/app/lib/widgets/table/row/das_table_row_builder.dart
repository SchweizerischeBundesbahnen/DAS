import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:flutter/widgets.dart';

/// Interface for a class that builds [DASTableRow]
abstract class DASTableRowBuilder<T> {
  static final Map<int, GlobalKey> _tableRowKeys = {};

  static GlobalKey _getRowKey(int identifier) {
    if (!_tableRowKeys.containsKey(identifier)) {
      _tableRowKeys[identifier] = GlobalKey();
    }
    return _tableRowKeys[identifier]!;
  }

  static void clearRowKeys() => _tableRowKeys.clear();

  DASTableRowBuilder({
    required this.height,
    required this.data,
    required this.rowIndex,
    this.decoration,
    this.stickyLevel = .none,
    this.identifier,
    GlobalKey? key,
  }) : key = key ?? _getRowKey(data.hashCode ^ rowIndex);

  DASTableRow build(BuildContext context);

  final double height;
  final StickyLevel stickyLevel;
  final T data;
  final int rowIndex;
  final DASTableRowDecoration? decoration;
  final String? identifier;
  final GlobalKey key;
}
