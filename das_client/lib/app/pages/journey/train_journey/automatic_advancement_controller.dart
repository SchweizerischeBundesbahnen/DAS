import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_level.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AutomaticAdvancementController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;
  static const int _screenIdleTimeSeconds = 10;

  AutomaticAdvancementController({ScrollController? controller}) : scrollController = controller ?? ScrollController();

  final ScrollController scrollController;
  BaseData? _currentPosition;
  List<DASTableRowBuilder> _renderedRows = [];
  Timer? _scrollTimer;
  double? _lastScrollPosition;
  DateTime? _lastTouch;

  final _rxIsAutomaticAdvancementActive = BehaviorSubject.seeded(false);

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  void handleJourneyUpdate({BaseData? currentPosition, bool automaticAdvancementActive = false}) {
    _currentPosition = currentPosition;
    _rxIsAutomaticAdvancementActive.add(automaticAdvancementActive);
    if (!automaticAdvancementActive) {
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

    final stickyHeaderHeights = {StickyLevel.first: 0.0, StickyLevel.second: 0.0};
    var targetScrollPosition = 0.0;

    for (final row in _renderedRows) {
      if (_currentPosition == row.data) {
        // remove the sticky header heights
        if (row.stickyLevel == StickyLevel.none) {
          targetScrollPosition -= stickyHeaderHeights.values.sum;
        } else if (row.stickyLevel == StickyLevel.second) {
          targetScrollPosition -= stickyHeaderHeights[StickyLevel.first]!;
        }

        return targetScrollPosition;
      }

      if (row.stickyLevel == StickyLevel.first) {
        stickyHeaderHeights[StickyLevel.first] = row.height;
        stickyHeaderHeights[StickyLevel.second] = 0.0;
      } else if (row.stickyLevel == StickyLevel.second) {
        stickyHeaderHeights[StickyLevel.second] = row.height;
      }

      targetScrollPosition += row.height;
    }

    return null;
  }

  void scrollToCurrentPosition() {
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
}
