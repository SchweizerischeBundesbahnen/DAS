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
    final breakSeries = settings.currentBreakSeries;

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

  @override
  void journeyIdentificationChanged(_) {}
}
