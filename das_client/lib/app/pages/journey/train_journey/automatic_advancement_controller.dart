import 'dart:async';
import 'dart:math';

import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/cupertino.dart';

class AutomaticAdvancementController {
  static const int _minScrollDuration = 500;
  static const int _maxScrollDuration = 2000;
  static const int _screenIdleTimeSeconds = 10;

  AutomaticAdvancementController({ScrollController? controller}) : scrollController = controller ?? ScrollController();

  final ScrollController scrollController;
  Journey? _lastJourney;
  TrainJourneySettings? _settings;
  List<BaseRowBuilder> _renderedRows = [];
  Timer? _scrollTimer;

  void updateRenderedRows(List<BaseRowBuilder> rows) {
    _renderedRows = rows;
  }

  void handleJourneyUpdate(Journey journey, TrainJourneySettings settings) {
    _settings = settings;
    if (!settings.automaticAdvancementActive) {
      _lastJourney = journey;
      return;
    }

    if (_lastJourney?.metadata.currentPosition?.order != journey.metadata.currentPosition?.order) {
      _lastJourney = journey;
      scrollToCurrentPosition();
    }
  }

  void scrollToCurrentPosition() {
    if (_lastJourney == null || scrollController.positions.isEmpty) return;

    var stickyRowHeight = 0.0;
    var targetScrollPosition = 0.0;

    for (final row in _renderedRows) {
      if (_lastJourney!.metadata.currentPosition == row.data) {
        if (!row.isSticky) {
          // remove the sticky header height
          targetScrollPosition -= stickyRowHeight;
        }

        // Adjust to maxScrollExtent so we don't overscroll
        targetScrollPosition = min(targetScrollPosition, scrollController.position.maxScrollExtent);

        Fimber.i('Scrolling to position $targetScrollPosition');
        scrollController.animateTo(
          targetScrollPosition,
          duration: _calculateDuration(targetScrollPosition, 1),
          curve: Curves.easeInOut,
        );
        break;
      }

      if (row.isSticky) {
        stickyRowHeight = row.height;
      }
      targetScrollPosition += row.height;
    }
  }

  void onTouch() {
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
}
