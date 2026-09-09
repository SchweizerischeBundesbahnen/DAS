import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_validation/journey_validation_view_model.dart';
import 'package:app/pages/journey/view_model/model/resolved_train_series_speed.dart';

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
// Hint: start by removing complete dir
class MultiLineSpeedViewModel({
  required final LineSpeedViewModel _lineSpeedViewModel,
  required final JourneyValidationViewModel _journeyValidationViewModel,
}) {
  List<ResolvedTrainSeriesSpeed> getResolvedSpeedsForOrder(int order) {
    final selectedBrakeSeries = _journeyValidationViewModel.brakeSeriesModelValue.selectedBrakeSeries;
    return selectedBrakeSeries
        .map((brakeSeries) => _lineSpeedViewModel.getResolvedSpeedForOrder(order, brakeSeries: brakeSeries))
        .toList(growable: false);
  }
}
