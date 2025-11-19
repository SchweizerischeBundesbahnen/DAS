import 'dart:async';
import 'dart:math';

import 'package:app/di/di.dart';
import 'package:app/util/time_constants.dart';
import 'package:app/util/widget_util.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
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

  final _idleTimeAutoScroll = DI.get<TimeConstants>().automaticAdvancementIdleTimeAutoScroll;

  JourneyTableScrollController({ScrollController? controller, GlobalKey? tableKey})
    : scrollController = controller ?? ScrollController(),
      tableKey = tableKey ?? GlobalKey();

  final ScrollController scrollController;
  final GlobalKey tableKey;
  JourneyPoint? _currentPosition;
  List<DASTableRowBuilder> _renderedRows = [];
  Timer? _scrollTimer;
  double? _lastScrollPosition;
  DateTime? _lastTouch;
  bool _isDisposed = false;

  final _rxIsAutomaticAdvancementActive = BehaviorSubject.seeded(false);

  bool get isActive => _rxIsAutomaticAdvancementActive.value;

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  // void handleJourneyUpdate({
  //   JourneyPoint? currentPosition,
  //   JourneyPoint? routeStart,
  //   ServicePoint? firstServicePoint,
  //   bool isAdvancementEnabledByUser = false,
  // }) {
  // if (_isDisposed) return;

  // _currentPosition = currentPosition;
  //
  // final firstServicePointOrder = firstServicePoint?.order ?? 0;
  // final currentPositionOrder = currentPosition?.order ?? 0;
  //
  // final isAdvancingActive =
  //     isAdvancementEnabledByUser && (currentPosition != routeStart) && currentPositionOrder >= firstServicePointOrder;
  // _log.fine(isAdvancingActive);
  // _rxIsAutomaticAdvancementActive.add(isAdvancingActive);
  // if (!isAdvancingActive) {
  //   return;
  // }
  //
  // final targetPosition = _calculateTargetPosition();
  // if (_lastScrollPosition != targetPosition && targetPosition != null && _lastTouch == null) {
  //   _scrollToPosition(targetPosition);
  // }
  // }

  void resetScrollTimer() {
    if (_isDisposed) return;

    _lastTouch = clock.now();
    if (_rxIsAutomaticAdvancementActive.value) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(Duration(seconds: _idleTimeAutoScroll), () {
        if (_rxIsAutomaticAdvancementActive.value) {
          _log.fine(
            'Screen idle time of $_idleTimeAutoScroll seconds reached. Scrolling to current position',
          );
          scrollToCurrentPosition();
        }
      });
    }
  }

  void scrollToCurrentPosition() {
    if (_isDisposed) return;

    _lastTouch = null;

    final targetPosition = _calculateTargetPosition(_currentPosition);
    if (targetPosition != null) {
      _scrollToPosition(targetPosition);
    }
  }

  void scrollToJourneyPoint(JourneyPoint? target) {
    if (_isDisposed) return;

    _lastTouch = null;

    final targetPosition = _calculateTargetPosition(target);
    if (targetPosition != null) {
      _scrollToPosition(targetPosition);
    }
  }

  void dispose() {
    _rxIsAutomaticAdvancementActive.close();
    _scrollTimer?.cancel();
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
    final stickyHeight = _calculateStickyHeight(targetPoint!);

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
      scrollDiff += _renderedRows[i].height;
    }
    return fromIndex > toIndex ? -scrollDiff : scrollDiff;
  }

  void _scrollToPosition(double targetScrollPosition) {
    _lastScrollPosition = targetScrollPosition;

    _log.fine('Scrolling to position $targetScrollPosition');
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
        stickyHeaderHeights[.first] = row.height;
        stickyHeaderHeights[.second] = 0.0;
      } else if (row.stickyLevel == .second) {
        stickyHeaderHeights[.second] = row.height;
      }
    }

    return 0.0;
  }
}
