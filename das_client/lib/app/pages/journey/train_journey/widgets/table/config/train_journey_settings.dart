import 'package:das_client/model/journey/break_series.dart';

class TrainJourneySettings {
  const TrainJourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;

  TrainJourneySettings copyWith({BreakSeries? selectedBreakSeries, List<int>? expandedGroups}) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
    );
  }
}
