import 'dart:async';

import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:app/pages/journey/settings/journey_settings_view_model.dart';
import 'package:sfera/component.dart';

class LineSpeedViewModel {
  LineSpeedViewModel({
    required JourneyTableViewModel journeyTableViewModel,
    required JourneySettingsViewModel journeySettingsViewModel,
  }) : _journeyTableViewModel = journeyTableViewModel,
       _journeySettingsViewModel = journeySettingsViewModel {
    _init();
  }

  final JourneyTableViewModel _journeyTableViewModel;
  final JourneySettingsViewModel _journeySettingsViewModel;
  Metadata? _lastMetadata;

  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = _journeyTableViewModel.journey.listen((journey) {
      _lastMetadata = journey?.metadata;
    });
  }

  ResolvedTrainSeriesSpeed getResolvedSpeedForOrder(int order) {
    final metadata = _lastMetadata;
    if (metadata == null) return ResolvedTrainSeriesSpeed.none();

    final settings = _journeySettingsViewModel.modelValue;
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

    final speed = trainSeriesSpeeds?.speedFor(breakSeries?.trainSeries, breakSeries: breakSeries?.breakSeries);

    return ResolvedTrainSeriesSpeed(
      speed: speed,
      isPrevious: speed != null ? isPrevious : false,
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
