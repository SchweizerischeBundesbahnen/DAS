import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyValidationViewModel');

const _maxSelectedBrakeSeries = 6;

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
// Hint: start by removing complete dir
class JourneyValidationViewModel({super.journeyViewModel}) extends JourneyAwareViewModel {
  final BehaviorSubject<MultiBrakeSeriesSelectionModel> _rxBrakeSeriesModel = BehaviorSubject.seeded(
    MultiBrakeSeriesSelectionModel(),
  );
  final BehaviorSubject<MultiBrakeSeriesSelectionModel> _rxEditingBrakeSeriesModel = BehaviorSubject.seeded(
    MultiBrakeSeriesSelectionModel(),
  );

  /// The last saved brake series selection.
  Stream<MultiBrakeSeriesSelectionModel> get brakeSeriesModel => _rxBrakeSeriesModel.stream.distinct();

  MultiBrakeSeriesSelectionModel get brakeSeriesModelValue => _rxBrakeSeriesModel.value;

  Stream<MultiBrakeSeriesSelectionModel> get editingBrakeSeriesModel => _rxEditingBrakeSeriesModel.stream.distinct();

  MultiBrakeSeriesSelectionModel get editingBrakeSeriesModelValue => _rxEditingBrakeSeriesModel.value;

  void startBrakeSeriesEditing() {
    _rxEditingBrakeSeriesModel.add(_rxBrakeSeriesModel.value);
  }

  void toggleBrakeSeriesSelection(BrakeSeries update) {
    final newlySelected = _currentBrakeSeriesWithToggled(update);

    _updateEditingBrakeSeries(newlySelected);
  }

  void saveBrakeSeriesSelection() {
    _rxBrakeSeriesModel.add(_rxEditingBrakeSeriesModel.value);
  }

  void _updateEditingBrakeSeries(List<BrakeSeries> update) {
    if (lastJourney == null) return;
    if (!_isValidSelection(update)) {
      _log.warning('called invalid selection: $update');
      return;
    }

    final availableBrakeSeries = Set<BrakeSeries>.from(lastJourney?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    _emitEditingBrakeSeriesModel(selectedBrakeSeries: update, availableBrakeSeries: availableBrakeSeries);
  }

  @override
  void onJourneyChanged(Journey? journey) {
    final selectedBrakeSeries = [journey?.metadata.brakeSeries].nonNulls.toList(growable: false);
    final availableBrakeSeries = Set<BrakeSeries>.from(journey?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    _emitBrakeSeriesModel(selectedBrakeSeries: selectedBrakeSeries, availableBrakeSeries: availableBrakeSeries);
    _emitEditingBrakeSeriesModel(selectedBrakeSeries: selectedBrakeSeries, availableBrakeSeries: availableBrakeSeries);
  }

  @override
  void dispose() {
    super.dispose();
    _rxBrakeSeriesModel.close();
    _rxEditingBrakeSeriesModel.close();
  }

  void _emitBrakeSeriesModel({
    required List<BrakeSeries> selectedBrakeSeries,
    required Set<BrakeSeries> availableBrakeSeries,
  }) {
    final model = _buildBrakeSeriesModel(
      selectedBrakeSeries: selectedBrakeSeries,
      availableBrakeSeries: availableBrakeSeries,
    );
    _log.fine('Emitting $model');
    _rxBrakeSeriesModel.add(model);
  }

  void _emitEditingBrakeSeriesModel({
    required List<BrakeSeries> selectedBrakeSeries,
    required Set<BrakeSeries> availableBrakeSeries,
  }) {
    final model = _buildBrakeSeriesModel(
      selectedBrakeSeries: selectedBrakeSeries,
      availableBrakeSeries: availableBrakeSeries,
    );
    _log.fine('Emitting editing $model');
    _rxEditingBrakeSeriesModel.add(model);
  }

  MultiBrakeSeriesSelectionModel _buildBrakeSeriesModel({
    required List<BrakeSeries> selectedBrakeSeries,
    required Set<BrakeSeries> availableBrakeSeries,
  }) {
    return MultiBrakeSeriesSelectionModel(
      selectedBrakeSeries: selectedBrakeSeries.sortedForDisplay,
      allowedBrakeSeries: _applyMultiSelectFilter(selectedBrakeSeries, availableBrakeSeries),
      availableBrakeSeries: availableBrakeSeries,
    );
  }

  Set<BrakeSeries> _applyMultiSelectFilter(
    List<BrakeSeries> selectedBrakeSeries,
    Set<BrakeSeries> availableBrakeSeries,
  ) {
    if (selectedBrakeSeries.isEmpty) return availableBrakeSeries;
    if (selectedBrakeSeries.length >= _maxSelectedBrakeSeries) return selectedBrakeSeries.toSet();
    final allowed = selectedBrakeSeries.expand((it) => it.trainSeries.combinableWith).toSet();
    return availableBrakeSeries.where((it) => allowed.contains(it.trainSeries)).toSet();
  }

  bool _isValidSelection(List<BrakeSeries> update) {
    if (update.isEmpty) return true;
    if (update.length > _maxSelectedBrakeSeries) return false;
    final availableBrakeSeries = Set<BrakeSeries>.from(lastJourney?.metadata.availableBrakeSeries ?? <BrakeSeries>{});
    if (!availableBrakeSeries.containsAll(update)) return false;
    final series = update.map((it) => it.trainSeries).toSet();
    return series.first.combinableWith.containsAll(series);
  }

  List<BrakeSeries> _currentBrakeSeriesWithToggled(BrakeSeries update) {
    final currentBrakeSeries = editingBrakeSeriesModelValue.selectedBrakeSeries;
    return currentBrakeSeries.contains(update)
        ? currentBrakeSeries.whereNot((it) => it == update).toList()
        : [...currentBrakeSeries, update];
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
