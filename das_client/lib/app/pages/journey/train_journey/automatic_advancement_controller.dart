import 'dart:math';

import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:flutter/cupertino.dart';

class AutomaticAdvancementController {
  static const int _minScrollDuration = 250;

  AutomaticAdvancementController({ScrollController? controller}) : scrollController = controller ?? ScrollController();

  final ScrollController scrollController;
  Journey? lastJourney;
  List<BaseRowBuilder> renderedRows = [];

  void updateRenderedRows(List<BaseRowBuilder> rows) {
    renderedRows = rows;
  }

  void handleJourneyUpdate(Journey journey, TrainJourneySettings settings) {
    if (!settings.automaticAdvancementActive) {
      lastJourney = journey;
      return;
    }

    if (lastJourney?.metadata.currentPosition?.order != journey.metadata.currentPosition?.order) {
      lastJourney = journey;
      scrollToCurrentPosition();
    }
  }

  void scrollToCurrentPosition() {
    if (lastJourney == null) return;

    var stickyRowHeight = 0.0;
    var targetScrollPosition = 0.0;

    for (final row in renderedRows) {
      if (lastJourney!.metadata.currentPosition == row.data) {
        if (!row.isSticky) {
          // remove the sticky header height
          targetScrollPosition -= stickyRowHeight;
        }

        // Adjust to maxScrollExtent so we don't overscroll
        targetScrollPosition = min(targetScrollPosition, scrollController.position.maxScrollExtent);

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

  Duration _calculateDuration(double targetPosition, double velocity) {
    if (velocity <= 0.0) {
      velocity = 1.0;
    }
    final durationMs = ((targetPosition - scrollController.offset).abs() / velocity).floor();

    return Duration(
      milliseconds: max(_minScrollDuration, durationMs),
    );
  }
}
