import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyValidationViewModel');

class JourneyValidationViewModel({super.journeyViewModel}) extends JourneyAwareViewModel {
  final BehaviorSubject<MultiBrakeSeriesSelectionModel> _rxBrakeSeriesModel = BehaviorSubject.seeded(
    MultiBrakeSeriesSelectionModel(),
  );
  final BehaviorSubject<bool> _rxValidationMode = BehaviorSubject.seeded(false);

  Stream<bool> get validationMode => _rxValidationMode.stream.distinct();

  bool get validationModeValue => _rxValidationMode.value;

  Stream<MultiBrakeSeriesSelectionModel> get brakeSeriesModel => _rxBrakeSeriesModel.stream.distinct();

  MultiBrakeSeriesSelectionModel get brakeSeriesModelValue => _rxBrakeSeriesModel.value;

  void toggleValidationMode() {
    _rxValidationMode.add(!_rxValidationMode.value);
  }

  void updateSelectedBrakeSeries(List<BrakeSeries> update) {
    if (lastJourney == null) return;
    if (!_isValidSelection(update)) {
      _log.warning('called updateSelectedBrakeSeries with invalid selection: $update');
      return;
    }

    final availableBrakeSeries = Set<BrakeSeries>.from(lastJourney?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    _emitBrakeSeriesModel(selectedBrakeSeries: update, availableBrakeSeries: availableBrakeSeries);
  }

  @override
  void onJourneyChanged(Journey? journey) {
    _emitBrakeSeriesModel(
      selectedBrakeSeries: [journey?.metadata.brakeSeries].nonNulls.toList(growable: false),
      availableBrakeSeries: Set.from(journey?.metadata.availableBrakeSeries ?? <BrakeSeries>{}),
    );
  }

  void _emitBrakeSeriesModel({
    required List<BrakeSeries> selectedBrakeSeries,
    required Set<BrakeSeries> availableBrakeSeries,
  }) {
    final model = MultiBrakeSeriesSelectionModel(
      selectedBrakeSeries: selectedBrakeSeries,
      allowedBrakeSeries: _applyMultiSelectFilter(selectedBrakeSeries, availableBrakeSeries),
      availableBrakeSeries: availableBrakeSeries,
    );
    _log.fine('Emitting $model');
    _rxBrakeSeriesModel.add(model);
  }

  Set<BrakeSeries> _applyMultiSelectFilter(
    List<BrakeSeries> selectedBrakeSeries,
    Set<BrakeSeries> availableBrakeSeries,
  ) {
    if (selectedBrakeSeries.isEmpty) return availableBrakeSeries;
    final allowed = selectedBrakeSeries.expand((it) => it.trainSeries.combinableWith).toSet();
    return availableBrakeSeries.where((it) => allowed.contains(it.trainSeries)).toSet();
  }

  bool _isValidSelection(List<BrakeSeries> update) {
    if (update.isEmpty) return true;
    final availableBrakeSeries = Set<BrakeSeries>.from(lastJourney?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    if (!availableBrakeSeries.containsAll(update)) return false;
    final series = update.map((it) => it.trainSeries).toSet();
    return series.first.combinableWith.containsAll(series);
  }
}

extension _TrainSeriesX on TrainSeries {
  static const _combinable = {TrainSeries.A, TrainSeries.D};

  Set<TrainSeries> get combinableWith => _combinable.contains(this) ? _combinable : {this};
}
