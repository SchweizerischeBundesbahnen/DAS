import 'package:das_client/model/journey/break_series.dart';

class TrainJourneySettings {
  const TrainJourneySettings(
      {this.selectedBreakSeries, this.expandedGroups = const [], this.automaticAdvancementActive = true});

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool automaticAdvancementActive;

  TrainJourneySettings copyWith(
      {BreakSeries? selectedBreakSeries, List<int>? expandedGroups, bool? automaticAdvancementActive}) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      automaticAdvancementActive: automaticAdvancementActive ?? this.automaticAdvancementActive,
    );
  }
}
