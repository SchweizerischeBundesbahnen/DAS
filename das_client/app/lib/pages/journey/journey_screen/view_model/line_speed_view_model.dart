import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/resolved_train_series_speed.dart';
import 'package:sfera/component.dart';

class LineSpeedViewModel extends JourneyAwareViewModel {
  LineSpeedViewModel({
    required JourneySettingsViewModel journeySettingsViewModel,
    super.journeyTableViewModel,
  }) : _journeySettingsViewModel = journeySettingsViewModel;

  final JourneySettingsViewModel _journeySettingsViewModel;

  ResolvedTrainSeriesSpeed getResolvedSpeedForOrder(int order) {
    final metadata = lastJourney?.metadata;
    if (metadata == null) return ResolvedTrainSeriesSpeed.none();

    final settings = _journeySettingsViewModel.modelValue;
    final brakeSeries = settings.currentBrakeSeries;

    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    var isPrevious = false;

    if (!_hasSpeed(trainSeriesSpeeds, brakeSeries)) {
      var lastKey = metadata.lineSpeeds.lastKeyBefore(order);
      while (!_hasSpeed(trainSeriesSpeeds, brakeSeries) && lastKey != null) {
        trainSeriesSpeeds = metadata.lineSpeeds[lastKey];
        lastKey = metadata.lineSpeeds.lastKeyBefore(lastKey);
        isPrevious = true;
      }
    }

    final speed = trainSeriesSpeeds?.speedFor(brakeSeries?.trainSeries, brakeSeries: brakeSeries?.brakeSeries);

    return ResolvedTrainSeriesSpeed(
      speed: speed,
      isPrevious: speed != null ? isPrevious : false,
    );
  }

  bool _hasSpeed(Iterable<TrainSeriesSpeed>? speeds, BrakeSeries? selectedBrakeSeries) {
    return speeds?.speedFor(
          selectedBrakeSeries?.trainSeries,
          brakeSeries: selectedBrakeSeries?.brakeSeries,
        ) !=
        null;
  }

  @override
  void journeyIdentificationChanged(_) {}
}
