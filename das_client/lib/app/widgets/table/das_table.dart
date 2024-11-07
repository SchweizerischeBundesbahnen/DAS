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
  DASTable({
    super.key,
    required this.columns,
    this.rows = const [],
    this.scrollController,
    this.bottomMargin = 32.0,
    this.themeData = const DASTableThemeData(
      backgroundColor: SBBColors.white,
      headingTextStyle: SBBTextStyles.smallLight,
      dataTextStyle: SBBTextStyles.largeLight,
      headingRowBorder: Border(bottom: BorderSide(width: 2, color: SBBColors.cloud)),
      tableBorder: TableBorder(
        horizontalInside: BorderSide(width: 1, color: SBBColors.cloud),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(sbbDefaultSpacing),
          topRight: Radius.circular(sbbDefaultSpacing),
        ),
      ),
    ),
  })  : assert(columns.isNotEmpty),
        assert(!rows.any((DASTableRow row) => row.cells.length != columns.length),
            'All rows must have the same number of cells as there are header cells (${columns.length})');

  /// List of rows to be displayed in the table.
  final List<DASTableRow> rows;

  /// List of columns defining the structure and heading of the table.
  final List<DASTableColumn> columns;

  /// Theme data used to style the table.
  final DASTableThemeData themeData;

  /// Scroll controller for managing scrollable content (rows) within the table.
  final ScrollController? scrollController;

  /// The bottom margin to be applied at the end of the scrollable content of the table.
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    return DASTableTheme(
      data: themeData,
      child: Container(
        decoration: BoxDecoration(
          color: themeData.backgroundColor,
          borderRadius: themeData.tableBorder?.borderRadius,
          border: BorderDirectional(
            top: themeData.tableBorder?.top ?? BorderSide.none,
            start: themeData.tableBorder?.left ?? BorderSide.none,
            end: themeData.tableBorder?.right ?? BorderSide.none,
            bottom: themeData.tableBorder?.bottom ?? BorderSide.none,
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

  Widget _headerRow() {
    return _FlexibleHeightRow(children: columns.map((column) => _headerCell(column)).toList());
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
    return _FlexibleHeightRow(
      fixedHeight: row.height,
      children: List.generate(columns.length, (index) {
        final cell = row.cells[index];
        final column = columns[index];
        return _dataCell(cell, column, row, isLast: columns.length - 1 == index);
      }),
    );
  }

  Widget _dataCell(DASTableCell cell, DASTableColumn column, DASTableRow row, {isLast = false}) {
    return Builder(builder: (context) {
      final tableThemeData = DASTableTheme.of(context)?.data;
      final effectiveAlignment = cell.alignment ?? column.alignment;
      return _TableCellWrapper(
        expanded: column.expanded,
        width: column.width,
        child: InkWell(
          onTap: cell.onTap,
          child: Container(
            decoration: BoxDecoration(
              border: cell.border ?? column.border ?? tableThemeData?.tableBorder?.toBoxBorder(isLastCell: isLast),
              color: cell.color ?? row.color ?? column.color ?? tableThemeData?.dataRowColor,
            ),
            padding: cell.padding ?? column.padding ?? EdgeInsets.all(sbbDefaultSpacing * 0.5),
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
}

extension _TableBorderExtension on TableBorder {
  toBoxBorder({bool isLastCell = false}) {
    return BorderDirectional(bottom: horizontalInside, end: isLastCell ? BorderSide.none : verticalInside);
  }
}

/// Row that handles height of its children with optional fixed height.
///
/// If [fixedHeight] is provided, the row will have that height; otherwise, it will use intrinsic height.
class _FlexibleHeightRow extends StatelessWidget {
  const _FlexibleHeightRow({this.fixedHeight, required this.children});

  final double? fixedHeight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final row = Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    if (fixedHeight != null) {
      return SizedBox(height: fixedHeight, child: row);
    }
    return IntrinsicHeight(child: row);
  }
}

/// A wrapper for table cells that allows for optional width and expansion.
class _TableCellWrapper extends StatelessWidget {
  const _TableCellWrapper({this.width, this.expanded = false, required this.child});

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
