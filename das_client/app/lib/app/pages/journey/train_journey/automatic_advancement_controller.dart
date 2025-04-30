import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:app/app/widgets/stickyheader/sticky_level.dart';
import 'package:app/app/widgets/table/das_table.dart';
import 'package:app/app/widgets/table/das_table_row.dart';
import 'package:app/model/journey/base_data.dart';
import 'package:app/util/widget_util.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AutomaticAdvancementController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;
  static const int _screenIdleTimeSeconds = 10;

  AutomaticAdvancementController({ScrollController? controller, GlobalKey? tableKey})
      : scrollController = controller ?? ScrollController(),
        tableKey = tableKey ?? GlobalKey();

  final ScrollController scrollController;
  final GlobalKey tableKey;
  BaseData? _currentPosition;
  List<DASTableRowBuilder> _renderedRows = [];
  Timer? _scrollTimer;
  double? _lastScrollPosition;
  DateTime? _lastTouch;

  final _rxIsAutomaticAdvancementActive = BehaviorSubject.seeded(false);

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  void handleJourneyUpdate({BaseData? currentPosition, BaseData? routeStart, bool isAdvancementEnabledByUser = false}) {
    _currentPosition = currentPosition;
    final isAdvancingActive = isAdvancementEnabledByUser && (currentPosition != routeStart);

    _rxIsAutomaticAdvancementActive.add(isAdvancingActive);
    if (!isAdvancingActive) {
      return;
    }

    final targetScrollPosition = _calculateScrollPosition();
    if (_lastScrollPosition != targetScrollPosition &&
        targetScrollPosition != null &&
        (_lastTouch == null ||
            _lastTouch!.add(Duration(seconds: _screenIdleTimeSeconds)).compareTo(DateTime.now()) < 0)) {
      _scrollToPosition(targetScrollPosition);
    }
  }

  double? _calculateScrollPosition() {
    if (_currentPosition == null || scrollController.positions.isEmpty) {
      return null;
    }

    final firstRenderedRow = _findFirstRenderedRow();
    if (firstRenderedRow == null) {
      Fimber.w('Failed to calculate scroll position: no rendered rows found');
      return null;
    }

    final fromIndex = _renderedRows.indexOf(firstRenderedRow);
    final toIndex = _renderedRows.indexWhere((it) => it.data == _currentPosition);

    if (fromIndex == -1 || toIndex == -1) {
      Fimber.w(
          'Failed to calculate scroll position because elements do not exist: fromIndex: $fromIndex, toIndex: $toIndex');
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
      Fimber.w('Failed to calculate scroll position: firstRowOffset: $firstRowOffset, listOffset: $listOffset');
      return null;
    }

    final renderedDiff = firstRowOffset.dy - listOffset.dy - DASTable.headerRowHeight;
    final stickyHeight = _calculateStickyHeight(_currentPosition!);

    Fimber.d(
        'currentpixels: ${scrollController.position.pixels}, renderedDiff: $renderedDiff, scrollDiff: $scrollDiff, stickyHeight: $stickyHeight');

    return scrollController.position.pixels + renderedDiff + scrollDiff - stickyHeight;
  }

  /// Scrolls to current position. If [resetAutomaticAdvancementTimer] is true, automatic advancement is started. Otherwise it waits till idle time is over.
  void scrollToCurrentPosition({bool resetAutomaticAdvancementTimer = false}) {
    if (resetAutomaticAdvancementTimer) {
      _lastTouch = null;
    }

    final targetScrollPosition = _calculateScrollPosition();
    if (targetScrollPosition != null) {
      _scrollToPosition(targetScrollPosition);
    }
  }

  void _scrollToPosition(double targetScrollPosition) {
    _lastScrollPosition = targetScrollPosition;

    Fimber.d('Scrolling to position $targetScrollPosition');
    scrollController.animateTo(
      targetScrollPosition,
      duration: _calculateDuration(targetScrollPosition, 1),
      curve: Curves.easeInOut,
    );
  }

  void resetScrollTimer() {
    _lastTouch = DateTime.now();
    if (_rxIsAutomaticAdvancementActive.value) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(seconds: _screenIdleTimeSeconds), () {
        if (_rxIsAutomaticAdvancementActive.value) {
          Fimber.d('Screen idle time of $_screenIdleTimeSeconds seconds reached. Scrolling to current position');
          scrollToCurrentPosition();
        }
      });
    }
  }

  void dispose() {
    _rxIsAutomaticAdvancementActive.close();
    _scrollTimer?.cancel();
  }

  Stream<bool> get isActiveStream => _rxIsAutomaticAdvancementActive.distinct();

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

  double _calculateStickyHeight(BaseData data) {
    final stickyHeaderHeights = {StickyLevel.first: 0.0, StickyLevel.second: 0.0};

    for (final row in _renderedRows) {
      if (data == row.data) {
        if (row.stickyLevel == StickyLevel.none) {
          return stickyHeaderHeights.values.sum;
        } else if (row.stickyLevel == StickyLevel.second) {
          return stickyHeaderHeights[StickyLevel.first]!;
        } else {
          return 0.0;
        }
      }

      if (row.stickyLevel == StickyLevel.first) {
        stickyHeaderHeights[StickyLevel.first] = row.height;
        stickyHeaderHeights[StickyLevel.second] = 0.0;
      } else if (row.stickyLevel == StickyLevel.second) {
        stickyHeaderHeights[StickyLevel.second] = row.height;
      }
    }

    return 0.0;
  }
}
