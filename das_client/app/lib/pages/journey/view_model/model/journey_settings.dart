import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;

  JourneySettings copyWith({
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
    bool? isAutoAdvancementEnabled,
  }) {
    return JourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
    );
  }

  BreakSeries? resolvedBreakSeries(Metadata? metadata) {
    return selectedBreakSeries ?? metadata?.breakSeries;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JourneySettings &&
        other.selectedBreakSeries == selectedBreakSeries &&
        const ListEquality().equals(other.expandedGroups, expandedGroups);
  }

  @override
  int get hashCode => selectedBreakSeries.hashCode ^ const ListEquality().hash(expandedGroups);
}
