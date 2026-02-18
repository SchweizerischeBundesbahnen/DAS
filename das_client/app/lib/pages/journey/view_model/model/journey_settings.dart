import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.initialBreakSeries,
    this.selectedBreakSeries,
    this.initialAvailableBreakSeries,
    this.expandedGroups = const [],
  });

  /// Initial BreakSeries of journey. Use this instead of [Metadata.breakSeries] as TC updates are ignored.
  final BreakSeries? initialBreakSeries;

  /// Initial available BreakSeries of journey. Use this instead of [Metadata.availableBreakSeries] as TC updates are ignored.
  final Set<BreakSeries>? initialAvailableBreakSeries;

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;

  JourneySettings copyWith({
    BreakSeries? initialBreakSeries,
    Set<BreakSeries>? initialAvailableBreakSeries,
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
  }) {
    return JourneySettings(
      initialBreakSeries: initialBreakSeries ?? this.initialBreakSeries,
      initialAvailableBreakSeries: initialAvailableBreakSeries ?? this.initialAvailableBreakSeries,
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
    );
  }

  BreakSeries? get currentBreakSeries => selectedBreakSeries ?? initialBreakSeries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneySettings &&
          runtimeType == other.runtimeType &&
          initialBreakSeries == other.initialBreakSeries &&
          selectedBreakSeries == other.selectedBreakSeries &&
          const SetEquality().equals(other.initialAvailableBreakSeries, initialAvailableBreakSeries) &&
          const ListEquality().equals(other.expandedGroups, expandedGroups);

  @override
  int get hashCode =>
      initialBreakSeries.hashCode ^
      selectedBreakSeries.hashCode ^
      const ListEquality().hash(expandedGroups) ^
      const SetEquality().hash(initialAvailableBreakSeries);
}
