import 'dart:async';

import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:sfera/component.dart';

class LineSpeedViewModel {
  LineSpeedViewModel({
    required TrainJourneyViewModel trainJourneyViewModel,
  }) : _trainJourneyViewModel = trainJourneyViewModel {
    _init();
  }

  final TrainJourneyViewModel _trainJourneyViewModel;
  Journey? _lastJourney;

  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = _trainJourneyViewModel.journey.listen((journey) {
      _lastJourney = journey;
    });
  }

  ResolvedTrainSeriesSpeed getResolvedSpeedForOrder(int order) {
    final metadata = _lastJourney?.metadata;
    if (metadata == null) return ResolvedTrainSeriesSpeed.none();

    final settings = _trainJourneyViewModel.settingsValue;
    final breakSeries = settings.resolvedBreakSeries(metadata);

    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    var isPrevious = false;

    if (!_hasSpeed(trainSeriesSpeeds, breakSeries)) {
      var lastKey = metadata.lineSpeeds.lastKeyBefore(order);
      while (!_hasSpeed(trainSeriesSpeeds, breakSeries) && lastKey != null) {
        trainSeriesSpeeds = metadata.lineSpeeds[lastKey];
        lastKey = metadata.lineSpeeds.lastKeyBefore(lastKey);
        isPrevious = true;
      }
    }

    return ResolvedTrainSeriesSpeed(
      speed: trainSeriesSpeeds?.speedFor(breakSeries?.trainSeries, breakSeries: breakSeries?.breakSeries),
      isPrevious: isPrevious,
    );
  }

  bool _hasSpeed(Iterable<TrainSeriesSpeed>? speeds, BreakSeries? selectedBreakSeries) {
    return speeds?.speedFor(
          selectedBreakSeries?.trainSeries,
          breakSeries: selectedBreakSeries?.breakSeries,
        ) !=
        null;
  }

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }
}
