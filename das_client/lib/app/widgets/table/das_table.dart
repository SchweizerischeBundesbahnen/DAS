import 'dart:math';

import 'package:collection/collection.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

/// [DASTable] provides a the basic structure for a train journey table.
///
/// The [columns] parameter must not be empty, and all rows must have the same number of cells as columns.
@immutable
class DASTable extends StatelessWidget {
  static const Key rowKey = Key('DAS-Table-row');
  static const double _headerRowHeight = 40.0;

  DASTable({
    required this.columns,
    super.key,
    this.rows = const [],
    this.scrollController,
    this.bottomMargin = 32.0,
    this.themeData,
  })  : assert(columns.isNotEmpty),
        assert(!rows.any((DASTableRow row) => row.cells.length != columns.length),
            'All rows must have the same number of cells as there are header cells (${columns.length})');

  /// List of rows to be displayed in the table.
  final List<DASTableRow> rows;

  /// List of columns defining the structure and heading of the table.
  final List<DASTableColumn> columns;

  /// Theme data used to style the table.
  final DASTableThemeData? themeData;

  /// Scroll controller for managing scrollable content (rows) within the table.
  final ScrollController? scrollController;

  /// The bottom margin to be applied at the end of the scrollable content of the table.
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    final tableThemeData = themeData ?? _defaultThemeData(context);
    return DASTableTheme(
      data: tableThemeData,
      child: Container(
        decoration: BoxDecoration(
          color: tableThemeData.backgroundColor,
          borderRadius: tableThemeData.tableBorder?.borderRadius,
          border: BorderDirectional(
            top: tableThemeData.tableBorder?.top ?? BorderSide.none,
            start: tableThemeData.tableBorder?.left ?? BorderSide.none,
            end: tableThemeData.tableBorder?.right ?? BorderSide.none,
            bottom: tableThemeData.tableBorder?.bottom ?? BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            _headerRow(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: rows.length + 1, // + 1 for bottom spacer
                itemBuilder: (context, index) {
                  if (index == rows.length) {
                    return SizedBox(height: bottomMargin);
                  }
                  return _dataRow(rows[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DASTableThemeData _defaultThemeData(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final borderColor = isDarkTheme ? SBBColors.iron : SBBColors.cloud;
    return DASTableThemeData(
      backgroundColor: isDarkTheme ? SBBColors.charcoal : SBBColors.white,
      headingTextStyle: SBBTextStyles.smallLight,
      dataTextStyle: SBBTextStyles.largeLight,
      headingRowBorder: Border(bottom: BorderSide(width: 2, color: borderColor)),
      tableBorder: TableBorder(
        horizontalInside: BorderSide(width: 1, color: borderColor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(sbbDefaultSpacing),
          topRight: Radius.circular(sbbDefaultSpacing),
        ),
      ),
    );
  }

  Widget _headerRow() {
    return _FixedHeightRow(
      height: _headerRowHeight,
      children: columns.where((column) => column.isVisible).map((column) => _headerCell(column)).toList(),
    );
  }

  Widget _headerCell(DASTableColumn column) {
    return Builder(builder: (context) {
      final tableThemeData = DASTableTheme.of(context)?.data;
      return _TableCellWrapper(
        expanded: column.expanded,
        width: column.width,
        child: Container(
          decoration: BoxDecoration(
            border: tableThemeData?.headingRowBorder ?? column.border,
            color: column.color ?? tableThemeData?.headingRowColor,
          ),
          padding: column.padding,
          child: column.child == null
              ? SizedBox.shrink()
              : DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.merge(tableThemeData?.headingTextStyle),
                  child: column.alignment != null
                      ? Align(alignment: column.alignment!, child: column.child)
                      : column.child!,
                ),
        ),
      );
    });
  }

  Widget _dataRow(DASTableRow row) {
    final visibleColumns = columns.where((column) => column.isVisible).toList(growable: false);
    final visibleCells = row.cells.whereIndexed((index, _) => columns[index].isVisible).toList(growable: false);
    return _FixedHeightRow(
      height: row.height,
      children: List.generate(visibleColumns.length, (index) {
        final cell = visibleCells[index];
        final column = visibleColumns[index];
        return _dataCell(cell, column, row, isLast: visibleColumns.length - 1 == index);
      }),
    );
  }

  Widget _dataCell(DASTableCell cell, DASTableColumn column, DASTableRow row, {isLast = false}) {
    return Builder(builder: (context) {
      final tableThemeData = DASTableTheme.of(context)?.data;
      final effectiveAlignment = cell.alignment ?? column.alignment;
      final BoxBorder? cellBorder =
          cell.border ?? column.border ?? tableThemeData?.tableBorder?.toBoxBorder(isLastCell: isLast);
      return _TableCellWrapper(
        expanded: column.expanded,
        width: column.width,
        child: InkWell(
          onTap: cell.onTap,
          child: Container(
            decoration: BoxDecoration(
              border: cellBorder,
              color: cell.color ?? row.color ?? column.color ?? tableThemeData?.dataRowColor,
            ),
            padding: _adjustPaddingToBorder(
                cell.padding ?? column.padding ?? EdgeInsets.all(sbbDefaultSpacing * 0.5), cellBorder),
            clipBehavior: cell.clipBehaviour,
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(tableThemeData?.dataTextStyle),
              child: effectiveAlignment != null ? Align(alignment: effectiveAlignment, child: cell.child) : cell.child,
            ),
          ),
        ),
      );
    });
  }

  EdgeInsets? _adjustPaddingToBorder(EdgeInsets? padding, BoxBorder? border) {
    if (padding == null || border == null) {
      return padding;
    }

    final borderSideStart = border is BorderDirectional ? border.start : (border as Border).left;
    final borderSideEnd = border is BorderDirectional ? border.end : (border as Border).right;

    return EdgeInsets.fromLTRB(max(padding.left - borderSideStart.width, 0), max(padding.top - border.top.width, 0),
        max(padding.right - borderSideEnd.width, 0), max(padding.bottom - border.bottom.width, 0));
  }
}

extension _TableBorderExtension on TableBorder {
  toBoxBorder({bool isLastCell = false}) {
    return BorderDirectional(bottom: horizontalInside, end: isLastCell ? BorderSide.none : verticalInside);
  }
}

class _FixedHeightRow extends StatelessWidget {
  const _FixedHeightRow({required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        key: DASTable.rowKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// A wrapper for table cells that allows for optional width and expansion.
class _TableCellWrapper extends StatelessWidget {
  const _TableCellWrapper({required this.child, this.width, this.expanded = false});

  /// The fixed width for the cell.
  final double? width;

  /// If true, the cell is wrapped with a Expanded widget.
  final bool expanded;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Expanded(child: child);
    } else if (width != null) {
      return SizedBox(width: width, child: child);
    } else {
      return child;
    }
  }
}
