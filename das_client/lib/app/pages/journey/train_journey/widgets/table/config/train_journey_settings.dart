import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/metadata.dart';

class TrainJourneySettings {
  const TrainJourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
    this.automaticAdvancementActive = true,
    this.maneuverMode = false,
    this.collapsedFootNotes = const [],
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool automaticAdvancementActive;
  final bool maneuverMode;
  final List<String> collapsedFootNotes;

  TrainJourneySettings copyWith({
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
    bool? automaticAdvancementActive,
    bool? maneuverMode,
    List<String>? collapsedFootNotes,
  }) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      automaticAdvancementActive: automaticAdvancementActive ?? this.automaticAdvancementActive,
      maneuverMode: maneuverMode ?? this.maneuverMode,
      collapsedFootNotes: collapsedFootNotes ?? this.collapsedFootNotes,
    );
  }

  BreakSeries? resolvedBreakSeries(Metadata? metadata) {
    return selectedBreakSeries ?? metadata?.breakSeries;
  }
}
