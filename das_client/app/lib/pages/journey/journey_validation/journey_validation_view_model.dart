import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyValidationViewModel');

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
// Hint: start by removing complete dir
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

  void toggleBrakeSeriesSelection(BrakeSeries update) {
    if (lastJourney == null) return;

    final newlySelected = _currentBrakeSeriesWithToggled(update);

    if (!_isValidSelection(newlySelected)) {
      _log.warning('called updateSelectedBrakeSeries with invalid selection: $newlySelected');
      return;
    }

    final availableBrakeSeries = Set<BrakeSeries>.from(lastJourney?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    _emitBrakeSeriesModel(selectedBrakeSeries: newlySelected, availableBrakeSeries: availableBrakeSeries);
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
      selectedBrakeSeries: selectedBrakeSeries.sortedForDisplay,
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

  List<BrakeSeries> _currentBrakeSeriesWithToggled(BrakeSeries update) {
    final currentBreakSeries = List<BrakeSeries>.from(brakeSeriesModelValue.selectedBrakeSeries);
    if (currentBreakSeries.contains(update)) {
      return [...currentBreakSeries.whereNot((it) => it == update)];
    } else {
      return [...currentBreakSeries, update];
    }
  }
}

extension _TrainSeriesX on TrainSeries {
  static const _combinable = <TrainSeries>{.A, .D};

  Set<TrainSeries> get combinableWith => _combinable.contains(this) ? _combinable : {this};
}

extension _BrakeSeriesListX on List<BrakeSeries> {
  List<BrakeSeries> get sortedForDisplay => sorted(
    (a, b) => a.trainSeries == b.trainSeries
        ? b.brakedWeightPercentage.compareTo(a.brakedWeightPercentage)
        : a.trainSeries.index.compareTo(b.trainSeries.index),
  );
}
