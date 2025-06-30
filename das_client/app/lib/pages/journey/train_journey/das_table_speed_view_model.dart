import 'dart:math';

import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class DASTableSpeedViewModel {
  const DASTableSpeedViewModel(this.journey, this.settings);

  final Journey journey;
  final TrainJourneySettings settings;

  Speed? previousSpeed(int rowIndex) {
    final currentBreakSeries = settings.resolvedBreakSeries(journey.metadata);
    final end = min(journey.data.length, rowIndex);
    final previousSpeedData = journey.data
        .getRange(0, end)
        .map((d) => d.speeds.speedFor(currentBreakSeries?.trainSeries, breakSeries: currentBreakSeries?.breakSeries))
        .nonNulls;

    return previousSpeedData.lastOrNull?.speed;
  }
}
