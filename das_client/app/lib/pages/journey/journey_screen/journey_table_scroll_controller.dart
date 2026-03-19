import 'dart:math';

import 'package:app/util/widget_util.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableScrollController');

/// Responsible for scrolling the [JourneyTable] to a specific JourneyPosition.
///
/// Use [scrollToJourneyPoint].
///
/// Reads the target row's position directly from the render tree so that the
/// calculation is always accurate regardless of row height changes or frame
/// ordering — no height summation is needed.
///
/// If the target row is outside the viewport and therefore not laid out, falls
/// back to the height-based calculation: it anchors on the nearest rendered
/// row and sums up [DASTableRowBuilder.height] values to reach the target.
class JourneyTableScrollController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;

  JourneyTableScrollController({ScrollController? controller, GlobalKey? tableKey})
    : scrollController = controller ?? ScrollController(),
      tableKey = tableKey ?? GlobalKey();

  final ScrollController scrollController;
  final GlobalKey tableKey;
  List<DASTableRowBuilder> _renderedRows = [];
  bool _isDisposed = false;

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  void scrollToJourneyPoint(JourneyPoint? target) {
    if (_isDisposed) return;

    // Defer by one frame so the layout for the current build is fully committed
    // before reading RenderBox positions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      final targetPosition = _calculateTargetPosition(target);
      if (targetPosition != null) {
        _scrollToPosition(targetPosition);
      }
    });
  }

  void dispose() {
    _isDisposed = true;
  }

  double? _calculateTargetPosition(JourneyPoint? targetPoint) {
    if (targetPoint == null || scrollController.positions.isEmpty) {
      return null;
    }

    final targetRow = _renderedRows.firstWhereOrNull((it) => it.data == targetPoint);
    if (targetRow == null) {
      _log.warning('Target journey point not found in rendered rows');
      return null;
    }

    final targetRenderObject = targetRow.key.currentContext?.findRenderObject() as RenderBox?;
    final tableRenderObject = tableKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetRenderObject != null && tableRenderObject != null) {
      return _calculatePositionFromRenderObject(targetPoint, targetRenderObject, tableRenderObject);
    }

    _log.fine('Target row not in viewport, falling back to height-based calculation');
    return _calculatePositionFromHeights(targetPoint);
  }

  /// Primary strategy: reads positions directly from the render tree.
  /// Accurate for any row that is currently laid out in the viewport.
  double _calculatePositionFromRenderObject(
    JourneyPoint targetPoint,
    RenderBox targetRenderObject,
    RenderBox tableRenderObject,
  ) {
    // Distance from the table's top (below the fixed header) to the
    // target row's top, **as currently painted**
    final distanceFromTableTop =
        targetRenderObject.localToGlobal(Offset.zero).dy -
        tableRenderObject.localToGlobal(Offset.zero).dy -
        DASTable.headerRowHeight;

    final stickyHeight = _calculateStickyHeight(targetPoint);

    _log.fine(
      'currentPixels: ${scrollController.position.pixels}, '
      'distanceFromTableTop: $distanceFromTableTop, stickyHeight: $stickyHeight',
    );

    // Shift the scroll position so the target row sits flush at the top of
    // the visible content area, just below any sticky header above it
    return scrollController.position.pixels + distanceFromTableTop - stickyHeight;
  }

  /// Fallback strategy: used when the target row is outside the viewport and
  /// therefore has no [RenderBox]. Anchors on the nearest rendered row and
  /// sums [DASTableRowBuilder.height] values to bridge the gap.
  double? _calculatePositionFromHeights(JourneyPoint targetPoint) {
    final firstRenderedRow = _findFirstRenderedRow();
    if (firstRenderedRow == null) {
      _log.warning('Failed to calculate scroll position: no rendered rows found');
      return null;
    }

    final fromIndex = _renderedRows.indexOf(firstRenderedRow);
    final toIndex = _renderedRows.indexWhere((it) => it.data == targetPoint);

    if (fromIndex == -1 || toIndex == -1) {
      _log.warning(
        'Failed to calculate scroll position because elements do not exist: fromIndex: $fromIndex, toIndex: $toIndex',
      );
      return null;
    }

    final scrollDiff = _calculateScrollDifference(fromIndex, toIndex);

    final firstRowOffset = WidgetUtil.findOffsetOfKey(firstRenderedRow.key);
    final listOffset = WidgetUtil.findOffsetOfKey(tableKey);

    if (firstRowOffset == null || listOffset == null) {
      _log.warning('Failed to calculate scroll position: firstRowOffset: $firstRowOffset, listOffset: $listOffset');
      return null;
    }

    final renderedDiff = firstRowOffset.dy - listOffset.dy - DASTable.headerRowHeight;
    final stickyHeight = _calculateStickyHeight(targetPoint);

    _log.fine(
      'currentPixels: ${scrollController.position.pixels}, renderedDiff: $renderedDiff, '
      'scrollDiff: $scrollDiff, stickyHeight: $stickyHeight',
    );

    return scrollController.position.pixels + renderedDiff + scrollDiff - stickyHeight;
  }

  double _calculateScrollDifference(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return 0.0;

    final start = min(fromIndex, toIndex);
    final end = max(fromIndex, toIndex);

    var scrollDiff = 0.0;
    for (int i = start; i < end; i++) {
      scrollDiff += _renderedRows[i].height;
    }
    return fromIndex > toIndex ? -scrollDiff : scrollDiff;
  }

  DASTableRowBuilder? _findFirstRenderedRow() {
    for (int i = 0; i < _renderedRows.length; i++) {
      final row = _renderedRows[i];
      if (row.key.currentContext != null) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        if (renderObject != null) {
          return _renderedRows[i];
        }
      }
    }
    return null;
  }

  void _scrollToPosition(double targetScrollPosition) {
    _log.finer('Scrolling to position $targetScrollPosition');
    scrollController.animateTo(
      targetScrollPosition,
      duration: _calculateDuration(targetScrollPosition),
      curve: Curves.easeInOut,
    );
  }

  Duration _calculateDuration(double targetPosition) {
    final linearDuration = ((targetPosition - scrollController.offset).abs()).floor();
    final boundedDuration = min(max(_minScrollDuration, linearDuration), _maxScrollDuration);
    return Duration(milliseconds: boundedDuration);
  }

  double _calculateStickyHeight(JourneyPoint data) {
    final stickyHeaderHeights = {StickyLevel.first: 0.0, StickyLevel.second: 0.0};

    for (final row in _renderedRows) {
      if (data == row.data) {
        if (row.stickyLevel == .none) {
          return stickyHeaderHeights.values.sum;
        } else if (row.stickyLevel == .second) {
          return stickyHeaderHeights[StickyLevel.first]!;
        } else {
          return 0.0;
        }
      }

      if (row.stickyLevel == .first) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        stickyHeaderHeights[.first] = renderObject?.size.height ?? row.height;
        stickyHeaderHeights[.second] = 0.0;
      } else if (row.stickyLevel == .second) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        stickyHeaderHeights[.second] = renderObject?.size.height ?? row.height;
      }
    }

    return 0.0;
  }
}
