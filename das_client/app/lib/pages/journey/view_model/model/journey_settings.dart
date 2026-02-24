import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.initialBrakeSeries,
    this.selectedBrakeSeries,
    this.expandedGroups = const [],
  });

  /// Initial BrakeSeries of journey. Use this instead of [Metadata.brakeSeries] as TC updates are ignored.
  final BrakeSeries? initialBrakeSeries;

  final BrakeSeries? selectedBrakeSeries;
  final List<int> expandedGroups;

  JourneySettings copyWith({
    BrakeSeries? initialBrakeSeries,
    BrakeSeries? selectedBrakeSeries,
    List<int>? expandedGroups,
  }) {
    return JourneySettings(
      initialBrakeSeries: initialBrakeSeries ?? this.initialBrakeSeries,
      selectedBrakeSeries: selectedBrakeSeries ?? this.selectedBrakeSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
    );
  }

  BrakeSeries? get currentBrakeSeries => selectedBrakeSeries ?? initialBrakeSeries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneySettings &&
          runtimeType == other.runtimeType &&
          initialBrakeSeries == other.initialBrakeSeries &&
          selectedBrakeSeries == other.selectedBrakeSeries &&
          const ListEquality().equals(other.expandedGroups, expandedGroups);

  @override
  int get hashCode =>
      initialBrakeSeries.hashCode ^ selectedBrakeSeries.hashCode ^ const ListEquality().hash(expandedGroups);
}
