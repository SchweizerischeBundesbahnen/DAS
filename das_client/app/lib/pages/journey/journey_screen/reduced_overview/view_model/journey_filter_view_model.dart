import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyFilterViewModel extends JourneyAwareViewModel {
  JourneyFilterViewModel({super.journeyViewModel}) {
    _updateFilters(lastJourney);
  }

  final _rxModel = BehaviorSubject<JourneyFilterModel?>.seeded(null);

  Stream<JourneyFilterModel?> get model => _rxModel.stream;

  JourneyFilterModel? get modelValue => _rxModel.value;

  void toggleFilter(FilterOption filter) {
    final currentModel = _rxModel.value;
    if (currentModel == null) return;

    final newModel = JourneyFilterModel(
      indication: _toggleFilter(currentModel.indication, filter),
      protectionSections: _toggleFilter(currentModel.protectionSections, filter),
      additionalSpeedRestrictions: _toggleFilter(currentModel.additionalSpeedRestrictions, filter),
      shortTermChanges: _toggleFilter(currentModel.shortTermChanges, filter),
      modifications: _toggleFilter(currentModel.modifications, filter),
    );
    _emit(newModel);
  }

  void resetFilters() {
    final currentModel = _rxModel.value;
    if (currentModel == null) return;

    final newModel = JourneyFilterModel(
      indication: FilterOption(active: false, affectedData: currentModel.indication.affectedData),
      protectionSections: FilterOption(active: false, affectedData: currentModel.protectionSections.affectedData),
      additionalSpeedRestrictions: FilterOption(
        active: false,
        affectedData: currentModel.additionalSpeedRestrictions.affectedData,
      ),
      shortTermChanges: FilterOption(active: false, affectedData: currentModel.shortTermChanges.affectedData),
      modifications: FilterOption(active: false, affectedData: currentModel.modifications.affectedData),
    );
    _emit(newModel);
  }

  FilterOption _toggleFilter(FilterOption original, FilterOption candidate) =>
      original == candidate ? FilterOption(active: !original.active, affectedData: original.affectedData) : original;

  @override
  void onJourneyChanged(Journey? journey) => _updateFilters(journey);

  @override
  void onJourneyUpdated(Journey? journey) => _updateFilters(journey);

  void _updateFilters(Journey? journey) {
    if (journey == null) {
      _reset();
      return;
    }

    final hints = _extractHints(journey);
    final protectionSections = _extractProtectionSections(journey);
    final speedRestrictions = _extractSpeedRestrictions(journey);
    final shortTermChanges = _extractShortTermChanges(journey);
    final tableModifications = _extractTableModifications(journey);

    final currentModel = _rxModel.value;

    _emit(
      JourneyFilterModel(
        indication: FilterOption(active: currentModel?.indication.active ?? false, affectedData: hints),
        protectionSections: FilterOption(
          active: currentModel?.protectionSections.active ?? false,
          affectedData: protectionSections,
        ),
        additionalSpeedRestrictions: FilterOption(
          active: currentModel?.additionalSpeedRestrictions.active ?? false,
          affectedData: speedRestrictions,
        ),
        shortTermChanges: FilterOption(
          active: currentModel?.shortTermChanges.active ?? false,
          affectedData: shortTermChanges,
        ),
        modifications: FilterOption(
          active: currentModel?.modifications.active ?? false,
          affectedData: tableModifications,
        ),
      ),
    );
  }

  List<BaseData> _extractHints(Journey journey) {
    return journey.data.where((data) => data is RuIndication || data is OperationalIndication).toList();
  }

  List<BaseData> _extractProtectionSections(Journey journey) {
    return journey.data.whereType<ProtectionSection>().where((it) => !it.shouldHide).toList();
  }

  List<BaseData> _extractSpeedRestrictions(Journey journey) {
    return journey.data.whereType<AdditionalSpeedRestrictionData>().where((it) => !it.shouldHide).toList();
  }

  List<BaseData> _extractShortTermChanges(Journey journey) {
    final affectedData = <BaseData>[];
    for (final data in journey.data) {
      final shortTermChangesAtOrder = journey.metadata.shortTermChanges.appliesToOrder(data.order);
      if (shortTermChangesAtOrder.where((it) => it is StopToPassChange || it is PassToStopChange).isNotEmpty) {
        affectedData.add(data);
      }
    }
    return affectedData;
  }

  List<BaseData> _extractTableModifications(Journey journey) {
    return journey.data
        .whereType<JourneyPoint>()
        .where((point) => point.hasModificationUpdated || (point.isDeleted && !point.shouldHide))
        .toList();
  }

  void _reset() {
    _rxModel.add(null);
  }

  void _emit(JourneyFilterModel model) {
    _rxModel.add(model);
  }

  @override
  void dispose() {
    super.dispose();
    _rxModel.close();
  }
}
