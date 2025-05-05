

import 'package:sfera/component.dart';

class TrainJourneySettings {
  const TrainJourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
    this.isAutoAdvancementEnabled = true,
    this.isManeuverModeEnabled = false,
    this.collapsedFootNotes = const [],
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool isAutoAdvancementEnabled;
  final bool isManeuverModeEnabled;
  final List<String> collapsedFootNotes;

  TrainJourneySettings copyWith({
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
    bool? isAutoAdvancementEnabled,
    bool? isManeuverModeEnabled,
    List<String>? collapsedFootNotes,
  }) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      isAutoAdvancementEnabled: isAutoAdvancementEnabled ?? this.isAutoAdvancementEnabled,
      isManeuverModeEnabled: isManeuverModeEnabled ?? this.isManeuverModeEnabled,
      collapsedFootNotes: collapsedFootNotes ?? this.collapsedFootNotes,
    );
  }

  BreakSeries? resolvedBreakSeries(Metadata? metadata) {
    return selectedBreakSeries ?? metadata?.breakSeries;
  }
}
