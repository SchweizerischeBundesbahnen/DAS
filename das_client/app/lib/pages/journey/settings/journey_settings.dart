import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
    this.isAutoAdvancementEnabled = true,
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool isAutoAdvancementEnabled;

  JourneySettings copyWith({
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
    bool? isAutoAdvancementEnabled,
  }) {
    return JourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      isAutoAdvancementEnabled: isAutoAdvancementEnabled ?? this.isAutoAdvancementEnabled,
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
        const ListEquality().equals(other.expandedGroups, expandedGroups) &&
        other.isAutoAdvancementEnabled == isAutoAdvancementEnabled;
  }

  @override
  int get hashCode =>
      selectedBreakSeries.hashCode ^ const ListEquality().hash(expandedGroups) ^ isAutoAdvancementEnabled.hashCode;
}
