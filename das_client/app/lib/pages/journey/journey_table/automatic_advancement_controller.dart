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

final _log = Logger('AutomaticAdvancementController');

class AutomaticAdvancementController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;

  final _idleTimeAutoScroll = DI.get<TimeConstants>().automaticAdvancementIdleTimeAutoScroll;

  AutomaticAdvancementController({ScrollController? controller, GlobalKey? tableKey})
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

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  void handleJourneyUpdate({
    JourneyPoint? currentPosition,
    JourneyPoint? routeStart,
    ServicePoint? firstServicePoint,
    bool isAdvancementEnabledByUser = false,
  }) {
    if (_isDisposed) return;

    _currentPosition = currentPosition;

    final firstServicePointOrder = firstServicePoint?.order ?? 0;
    final currentPositionOrder = currentPosition?.order ?? 0;

    final isAdvancingActive =
        isAdvancementEnabledByUser && (currentPosition != routeStart) && currentPositionOrder >= firstServicePointOrder;

    _rxIsAutomaticAdvancementActive.add(isAdvancingActive);
    if (!isAdvancingActive) {
      return;
    }

    final targetScrollPosition = _calculateScrollPosition();
    if (_lastScrollPosition != targetScrollPosition &&
        targetScrollPosition != null &&
        (_lastTouch == null || _lastTouch!.add(Duration(seconds: _idleTimeAutoScroll)).compareTo(clock.now()) < 0)) {
      _scrollToPosition(targetScrollPosition);
    }
  }

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

    final targetScrollPosition = _calculateScrollPosition();
    if (targetScrollPosition != null) {
      _scrollToPosition(targetScrollPosition);
    }
  }

  void dispose() {
    _rxIsAutomaticAdvancementActive.close();
    _scrollTimer?.cancel();
    _isDisposed = true;
  }

  double? _calculateScrollPosition() {
    if (_currentPosition == null || scrollController.positions.isEmpty) {
      return null;
    }

    final firstRenderedRow = _findFirstRenderedRow();
    if (firstRenderedRow == null) {
      _log.warning('Failed to calculate scroll position: no rendered rows found');
      return null;
    }

    final fromIndex = _renderedRows.indexOf(firstRenderedRow);
    final toIndex = _renderedRows.indexWhere((it) => it.data == _currentPosition);

    if (fromIndex == -1 || toIndex == -1) {
      _log.warning(
        'Failed to calculate scroll position because elements do not exist: fromIndex: $fromIndex, toIndex: $toIndex',
      );
      return null;
    }

    var scrollDiff = 0.0;
    if (fromIndex > toIndex) {
      // Scroll up
      for (int i = fromIndex - 1; i >= toIndex; i--) {
        final row = _renderedRows[i];
        scrollDiff -= row.height;
      }
    } else if (toIndex > fromIndex) {
      // Scroll down
      for (int i = fromIndex; i < toIndex; i++) {
        final row = _renderedRows[i];
        scrollDiff += row.height;
      }
    }

    final firstRowOffset = WidgetUtil.findOffsetOfKey(firstRenderedRow.key);
    final listOffset = WidgetUtil.findOffsetOfKey(tableKey);

    if (firstRowOffset == null || listOffset == null) {
      _log.warning('Failed to calculate scroll position: firstRowOffset: $firstRowOffset, listOffset: $listOffset');
      return null;
    }

    final renderedDiff = firstRowOffset.dy - listOffset.dy - DASTable.headerRowHeight;
    final stickyHeight = _calculateStickyHeight(_currentPosition!);

    _log.fine(
      'currentpixels: ${scrollController.position.pixels}, renderedDiff: $renderedDiff, scrollDiff: $scrollDiff, stickyHeight: $stickyHeight',
    );

    return scrollController.position.pixels + renderedDiff + scrollDiff - stickyHeight;
  }

  void _scrollToPosition(double targetScrollPosition) {
    _lastScrollPosition = targetScrollPosition;

    _log.fine('Scrolling to position $targetScrollPosition');
    scrollController.animateTo(
      targetScrollPosition,
      duration: _calculateDuration(targetScrollPosition, 1),
      curve: Curves.easeInOut,
    );
  }

  bool get isActive => _rxIsAutomaticAdvancementActive.value;

  Duration _calculateDuration(double targetPosition, double velocity) {
    if (velocity <= 0.0) {
      velocity = 1.0;
    }
    final durationMs = ((targetPosition - scrollController.offset).abs() / velocity).floor();

    return Duration(
      milliseconds: min(max(_minScrollDuration, durationMs), _maxScrollDuration),
    );
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
