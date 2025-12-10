import 'dart:math';

import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:app/widgets/table/scrollable_align.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// [DASTable] provides a the basic structure for a train journey table.
///
/// The [columns] parameter must not be empty, and all rows must have the same number of cells as columns.
@immutable
class DASTable extends StatefulWidget {
  static const Key tableKey = Key('dasTable');
  static const Key rowKey = Key('dasTableRow');
  static const Key columnHeaderKey = Key('dasTableColumnHeader');
  static const double headerRowHeight = 40.0;

  DASTable({
    required this.columns,
    super.key,
    this.rows = const [],
    ScrollController? scrollController,
    this.minBottomMargin = 128.0,
    this.bottomMarginAdjustment = 0,
    this.themeData,
    this.alignToItem = true,
    this.addBottomSpacer = true,
    this.hasStickyRows = true,
  }) : assert(columns.isNotEmpty),
       scrollController = scrollController ?? ScrollController();

  /// List of rows to be displayed in the table.
  final List<DASTableRow> rows;

  /// List of columns defining the structure and heading of the table.
  final List<DASTableColumn> columns;

  /// Theme data used to style the table.
  final DASTableThemeData? themeData;

  /// Scroll controller for managing scrollable content (rows) within the table.
  final ScrollController scrollController;

  /// The bottom margin to be applied at the end of the scrollable content of the table.
  final double minBottomMargin;

  /// bottom margin can be adjusted to handle sticky headers
  final double bottomMarginAdjustment;

  /// defines if the listview should always align the scroll position to an item after scrolling
  final bool alignToItem;

  /// If true, a bottom spacer is added to the table to ensure the last row can be scrolled to the top.
  final bool addBottomSpacer;

  /// If the table uses sticky rows this bool will activate the sticky widgets.
  final bool hasStickyRows;

  @override
  State<DASTable> createState() => _DASTableState();
}

class _DASTableState extends State<DASTable> {
  final _animatedListKey = GlobalKey<AnimatedListState>();
  static const _tableInsertRemoveAnimationDurationMs = 500;

  @override
  void didUpdateWidget(DASTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateItemCount(oldWidget);
    _calculateInsertAndRemoveAnimation(oldWidget);
  }

  void _updateItemCount(DASTable oldWidget) {
    final oldLength = oldWidget.rows.length;
    final newLength = widget.rows.length;
    final diff = (oldLength - newLength).abs();

    if (oldLength < newLength) {
      for (int i = 0; i < diff; i++) {
        _animatedListKey.currentState!.insertItem(oldLength + i, duration: Duration.zero);
      }
    } else if (oldLength > newLength) {
      for (int i = 0; i < diff; i++) {
        _animatedListKey.currentState!.removeItem(
          oldLength - i,
          (context, animation) => Container(),
          duration: Duration.zero,
        );
      }
    }
  }

  void _calculateInsertAndRemoveAnimation(DASTable oldWidget) {
    if (oldWidget.rows.length != widget.rows.length) {
      // we only animate if the number of rows is the same (line foot notes moving)
      return;
    }

    for (int i = 0; i < oldWidget.rows.length && i < widget.rows.length; i++) {
      final oldRow = oldWidget.rows[i];
      if (oldRow.identifier != null && widget.rows[i].identifier != oldRow.identifier) {
        _animatedListKey.currentState!.removeItem(i, (context, animation) {
          return SizeTransition(sizeFactor: animation, child: _dataRow(oldRow));
        }, duration: Duration(milliseconds: _tableInsertRemoveAnimationDurationMs));
      }
    }

    for (int i = 0; i < widget.rows.length && i < oldWidget.rows.length; i++) {
      final newRow = widget.rows[i];
      if (newRow.identifier != null && oldWidget.rows[i].identifier != newRow.identifier) {
        _animatedListKey.currentState!.insertItem(
          i,
          duration: Duration(milliseconds: _tableInsertRemoveAnimationDurationMs),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tableThemeData = widget.themeData ?? _defaultThemeData(context);
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
            Expanded(child: widget.hasStickyRows ? _stickyHeaderList() : _animatedList()),
          ],
        ),
      ),
    );
  }

  Widget _stickyHeaderList() {
    return StickyHeader(
      footerBuilder: (context, index) => _footer(index),
      headerBuilder: (context, index) => ClipRect(child: _dataRow(widget.rows[index], isSticky: true)),
      scrollController: widget.scrollController,
      rows: widget.rows,
      child: _animatedList(),
    );
  }

  Container _footer(int index) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: SBBColors.black.withAlpha((255.0 * 0.2).round()),
            blurRadius: 5,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRect(
        child: _dataRow(widget.rows[index], isSticky: true),
      ),
    );
  }

  Widget _animatedList() {
    final list = KeyedSubtree(
      key: DASTable.tableKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedList(
            physics: ClampingScrollPhysics(),
            key: _animatedListKey,
            controller: widget.scrollController,
            initialItemCount: widget.rows.length + 1,
            itemBuilder: (context, index, animation) {
              if (index == widget.rows.length) return _bottomMargin(constraints);

              return SizeTransition(
                key: widget.rows[index].key,
                sizeFactor: animation,
                child: _dataRow(widget.rows[index]),
              );
            },
          );
        },
      ),
    );

    return widget.alignToItem
        ? ScrollableAlign(scrollController: widget.scrollController, rows: widget.rows, child: list)
        : list;
  }

  Widget _bottomMargin(BoxConstraints constraints) {
    final bottomMargin = widget.addBottomSpacer ? constraints.maxHeight - widget.bottomMarginAdjustment : 0.0;
    return SizedBox(height: max(bottomMargin, widget.minBottomMargin));
  }

  DASTableThemeData _defaultThemeData(BuildContext context) {
    final isDarkTheme = ThemeUtil.isDarkMode(context);
    final borderColor = isDarkTheme ? SBBColors.iron : SBBColors.cloud;
    return DASTableThemeData(
      backgroundColor: isDarkTheme ? SBBColors.charcoal : SBBColors.white,
      headingTextStyle: DASTextStyles.smallLight,
      dataTextStyle: DASTextStyles.largeRoman,
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
      height: DASTable.headerRowHeight,
      children: widget.columns.map((column) => _headerCell(column)).toList(),
    );
  }

  Widget _headerCell(DASTableColumn column) {
    return Builder(
      builder: (context) {
        final tableThemeData = DASTableTheme.of(context)?.data;
        final headerCell = KeyedSubtree(
          key: DASTable.columnHeaderKey,
          child: _TableCellWrapper(
            expanded: column.expanded,
            width: column.width,
            child: Container(
              key: column.headerKey,
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
          ),
        );
        return column.onTap != null
            ? GestureDetector(
                onTap: column.onTap,
                child: headerCell,
              )
            : headerCell;
      },
    );
  }

  Widget _dataRow(DASTableRow row, {bool isSticky = false}) {
    if (row is! DASTableCellRow) {
      return KeyedSubtree(key: DASTable.rowKey, child: (row as DASTableWidgetRow).widget);
    }

    return InkWell(
      onTap: row.onTap,
      child: DASRowControllerWrapper(
        isAlwaysSticky: isSticky,
        rowKey: row.key,
        child: _FixedHeightRow(
          height: row.height,
          children: List.generate(widget.columns.length, (index) {
            final column = widget.columns[index];
            final cell = row.cells[column.id] ?? DASTableCell.empty();
            return _dataCell(cell, column, row, isLast: widget.columns.length - 1 == index);
          }),
        ),
      ),
    );
  }

  Widget _dataCell(DASTableCell cell, DASTableColumn column, DASTableCellRow row, {isLast = false}) {
    return Builder(
      builder: (context) {
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
                cell.padding ?? column.padding ?? .all(sbbDefaultSpacing * 0.5),
                cellBorder,
              ),
              clipBehavior: cell.clipBehavior,
              child: DefaultTextStyle(
                style: DefaultTextStyle.of(context).style.merge(tableThemeData?.dataTextStyle),
                child: effectiveAlignment != null
                    ? Align(alignment: effectiveAlignment, child: cell.child)
                    : cell.child,
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets? _adjustPaddingToBorder(EdgeInsets? padding, BoxBorder? border) {
    if (padding == null || border == null) {
      return padding;
    }

    final borderSideStart = border is BorderDirectional ? border.start : (border as Border).left;
    final borderSideEnd = border is BorderDirectional ? border.end : (border as Border).right;

    return .fromLTRB(
      max(padding.left - borderSideStart.width, 0),
      max(padding.top - border.top.width, 0),
      max(padding.right - borderSideEnd.width, 0),
      max(padding.bottom - border.bottom.width, 0),
    );
  }
}

extension _TableBorderExtension on TableBorder {
  BorderDirectional toBoxBorder({bool isLastCell = false}) {
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
        crossAxisAlignment: .stretch,
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
