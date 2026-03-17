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
/// Calculates target scroll position respecting currently rendered rows and sticky header.
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

    // Two nested post-frame callbacks are needed:
    //
    // - updateRenderedRows() in journey_table.dart is also deferred via a
    //   single addPostFrameCallback, registered during the same build that
    //   triggers this call.
    // - Post-frame callbacks fire in registration order within the same frame.
    //   If scrollToJourneyPoint is called before the build completes (e.g. from
    //   the advancement view model reacting to the same stream event), our
    //   outer callback lands in the same batch as updateRenderedRows's callback
    //   but may run before it, leaving _renderedRows still holding the old list.
    //
    // The inner callback is therefore scheduled from inside the outer one,
    // guaranteeing it runs one full frame after updateRenderedRows has already
    // swapped in the new builder list and the new layout is fully committed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed) return;
        final targetPosition = _calculateTargetPosition(target);
        if (targetPosition != null) {
          _scrollToPosition(targetPosition);
        }
      });
    });
  }

  void dispose() {
    _isDisposed = true;
  }

  double? _calculateTargetPosition(JourneyPoint? targetPoint) {
    if (targetPoint == null || scrollController.positions.isEmpty) {
      return null;
    }

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
      'currentpixels: ${scrollController.position.pixels}, renderedDiff: $renderedDiff, scrollDiff: $scrollDiff, stickyHeight: $stickyHeight',
    );

    return scrollController.position.pixels + renderedDiff + scrollDiff - stickyHeight;
  }

  double _calculateScrollDifference(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return 0.0;

    final start = min(fromIndex, toIndex);
    final end = max(fromIndex, toIndex);

    var scrollDiff = 0.0;
    for (int i = start; i < end; i++) {
      scrollDiff += _actualRowHeight(_renderedRows[i]);
    }
    return fromIndex > toIndex ? -scrollDiff : scrollDiff;
  }

  double _actualRowHeight(DASTableRowBuilder row) {
    final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
    return renderObject?.size.height ?? row.height;
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
        stickyHeaderHeights[.first] = _actualRowHeight(row);
        stickyHeaderHeights[.second] = 0.0;
      } else if (row.stickyLevel == .second) {
        stickyHeaderHeights[.second] = _actualRowHeight(row);
      }
    }

    return 0.0;
  }
}
