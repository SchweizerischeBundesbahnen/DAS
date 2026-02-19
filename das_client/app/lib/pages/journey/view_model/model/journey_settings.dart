import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.initialBreakSeries,
    this.selectedBreakSeries,
    this.expandedGroups = const [],
  });

  /// Initial BreakSeries of journey. Use this instead of [Metadata.breakSeries] as TC updates are ignored.
  final BreakSeries? initialBreakSeries;

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;

  JourneySettings copyWith({
    BreakSeries? initialBreakSeries,
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
  }) {
    return JourneySettings(
      initialBreakSeries: initialBreakSeries ?? this.initialBreakSeries,
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
          const ListEquality().equals(other.expandedGroups, expandedGroups);

  @override
  int get hashCode =>
      initialBreakSeries.hashCode ^ selectedBreakSeries.hashCode ^ const ListEquality().hash(expandedGroups);
}
