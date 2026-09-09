import 'package:core_data/component.dart';

/// Represents a single filter option with its active state and affected data
class FilterOption {
  final bool active;
  final List<BaseData> affectedData;

  const FilterOption({
    required this.active,
    required this.affectedData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          active == other.active &&
          affectedData == other.affectedData;

  @override
  int get hashCode => Object.hash(active, affectedData);
}

class JourneyFilterModel({
  required final FilterOption indication,
  required final FilterOption protectionSections,
  required final FilterOption additionalSpeedRestrictions,
  required final FilterOption shortTermChanges,
  required final FilterOption modifications,
}) {
  List<FilterOption> get allFilters => [
    indication,
    protectionSections,
    additionalSpeedRestrictions,
    shortTermChanges,
    modifications,
  ];

  /// Returns all data that should should be displayed based on active filters
  Set<BaseData> getFilteredData() {
    final data = <BaseData>{};
    for (final filter in allFilters) {
      if (!filter.active) data.addAll(filter.affectedData);
    }
    return data;
  }

  bool get hasData =>
      indication.affectedData.isNotEmpty ||
      protectionSections.affectedData.isNotEmpty ||
      additionalSpeedRestrictions.affectedData.isNotEmpty ||
      shortTermChanges.affectedData.isNotEmpty ||
      modifications.affectedData.isNotEmpty;

  @override
  String toString() =>
      'JourneyFilterLoaded{'
      'indication: $indication, '
      'protectionSections: $protectionSections, '
      'additionalSpeedRestrictions: $additionalSpeedRestrictions, '
      'shortTermChanges: $shortTermChanges, '
      'modifications: $modifications'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyFilterModel &&
          runtimeType == other.runtimeType &&
          indication == other.indication &&
          protectionSections == other.protectionSections &&
          additionalSpeedRestrictions == other.additionalSpeedRestrictions &&
          shortTermChanges == other.shortTermChanges &&
          modifications == other.modifications;

  @override
  int get hashCode => Object.hash(
    indication,
    protectionSections,
    additionalSpeedRestrictions,
    shortTermChanges,
    modifications,
  );
}
