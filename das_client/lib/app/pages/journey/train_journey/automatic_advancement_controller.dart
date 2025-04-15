import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_level.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/util/widget_util.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/cupertino.dart';

class AutomaticAdvancementController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;
  static const int _screenIdleTimeSeconds = 10;
  static const double _dasTableHeaderHeight = 40.0;

  AutomaticAdvancementController({ScrollController? controller, GlobalKey? tableKey})
      : scrollController = controller ?? ScrollController(),
        tableKey = tableKey ?? GlobalKey();

  final ScrollController scrollController;
  final GlobalKey tableKey;
  Journey? _currentJourney;
  TrainJourneySettings? _settings;
  List<DASTableRowBuilder> _renderedRows = [];
  Timer? _scrollTimer;
  double? _lastScrollPosition;
  DateTime? _lastTouch;

  void updateRenderedRows(List<DASTableRowBuilder> rows) {
    _renderedRows = rows;
  }

  void handleJourneyUpdate(Journey journey, TrainJourneySettings settings) {
    _currentJourney = journey;
    _settings = settings;

    if (!settings.automaticAdvancementActive) {
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
    if (_currentJourney == null ||
        _currentJourney?.metadata.currentPosition == null ||
        scrollController.positions.isEmpty) {
      return null;
    }

    final firstRenderedRow = _findFirstRenderedRow();
    if (firstRenderedRow == null) {
      Fimber.w('Failed to calculate scroll position: no rendered rows found');
      return null;
    }

    final fromIndex = _renderedRows.indexOf(firstRenderedRow);
    final toIndex = _renderedRows.indexWhere((it) => it.data == _currentJourney!.metadata.currentPosition);

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

    final renderedDiff = firstRowOffset.dy - listOffset.dy - _dasTableHeaderHeight;
    final stickyHeight = _calculateStickyHeight(_currentJourney!.metadata.currentPosition!);

    Fimber.d(
        'currentpixels: ${scrollController.position.pixels}, renderedDiff: $renderedDiff, scrollDiff: $scrollDiff, stickyHeight: $stickyHeight');

    return scrollController.position.pixels + renderedDiff + scrollDiff - stickyHeight;
  }

  void scrollToCurrentPosition() {
    final targetScrollPosition = _calculateScrollPosition();
    if (targetScrollPosition != null) {
      _scrollToPosition(targetScrollPosition);
    }
  }

  void _scrollToPosition(double targetScrollPosition) {
    _lastScrollPosition = targetScrollPosition;

    Fimber.i('Scrolling to position $targetScrollPosition');
    scrollController.animateTo(
      targetScrollPosition,
      duration: _calculateDuration(targetScrollPosition, 1),
      curve: Curves.easeInOut,
    );
  }

  void onTouch() {
    _lastTouch = DateTime.now();
    if (_settings?.automaticAdvancementActive == true) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(seconds: _screenIdleTimeSeconds), () {
        if (_settings?.automaticAdvancementActive == true) {
          Fimber.i('Screen idle time of $_screenIdleTimeSeconds seconds reached. Scrolling to current position');
          scrollToCurrentPosition();
        }
      });
    }
  }

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
