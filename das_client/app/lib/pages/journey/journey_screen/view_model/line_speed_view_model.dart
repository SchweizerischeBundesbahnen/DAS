import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/resolved_train_series_speed.dart';
import 'package:sfera/component.dart';

class LineSpeedViewModel({
  required final JourneySettingsViewModel _journeySettingsViewModel,
  super.journeyViewModel,
}) extends JourneyAwareViewModel {
  ResolvedTrainSeriesSpeed getResolvedSpeedForOrder(int order, {BrakeSeries? brakeSeries}) {
    final metadata = lastJourney?.metadata;
    if (metadata == null) return ResolvedTrainSeriesSpeed.none();

    final resolvedBrakeSeries = brakeSeries ?? _journeySettingsViewModel.modelValue.currentBrakeSeries;

    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    var isPrevious = false;

    if (!_hasSpeed(trainSeriesSpeeds, resolvedBrakeSeries)) {
      var lastKey = metadata.lineSpeeds.lastKeyBefore(order);
      while (!_hasSpeed(trainSeriesSpeeds, resolvedBrakeSeries) && lastKey != null) {
        trainSeriesSpeeds = metadata.lineSpeeds[lastKey];
        lastKey = metadata.lineSpeeds.lastKeyBefore(lastKey);
        isPrevious = true;
      }
    }

    final speed = trainSeriesSpeeds?.speedFor(
      resolvedBrakeSeries?.trainSeries,
      brakedWeightPercentage: resolvedBrakeSeries?.brakedWeightPercentage,
    );

    return ResolvedTrainSeriesSpeed(
      speed: speed,
      isPrevious: speed != null ? isPrevious : false,
    );
  }

  bool _hasSpeed(Iterable<TrainSeriesSpeed>? speeds, BrakeSeries? selectedBrakeSeries) {
    return speeds?.speedFor(
          selectedBrakeSeries?.trainSeries,
          brakedWeightPercentage: selectedBrakeSeries?.brakedWeightPercentage,
        ) !=
        null;
  }
}
