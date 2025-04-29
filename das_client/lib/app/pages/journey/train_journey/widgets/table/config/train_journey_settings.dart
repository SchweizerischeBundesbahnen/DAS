import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/metadata.dart';

class TrainJourneySettings {
  const TrainJourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
    this.isAutoAdvancementEnabledByUser = true,
    this.isManeuverModeEnabledByUser = false,
    this.collapsedFootNotes = const [],
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool isAutoAdvancementEnabledByUser;
  final bool isManeuverModeEnabledByUser;
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
      isAutoAdvancementEnabledByUser: automaticAdvancementActive ?? this.isAutoAdvancementEnabledByUser,
      isManeuverModeEnabledByUser: maneuverMode ?? this.isManeuverModeEnabledByUser,
      collapsedFootNotes: collapsedFootNotes ?? this.collapsedFootNotes,
    );
  }

  BreakSeries? resolvedBreakSeries(Metadata? metadata) {
    return selectedBreakSeries ?? metadata?.breakSeries;
  }
}
