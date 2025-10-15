import 'package:sfera/component.dart';

class TrainJourneySettings {
  const TrainJourneySettings({
    this.selectedBreakSeries,
    this.expandedGroups = const [],
    this.isAutoAdvancementEnabled = true,
  });

  final BreakSeries? selectedBreakSeries;
  final List<int> expandedGroups;
  final bool isAutoAdvancementEnabled;

  TrainJourneySettings copyWith({
    BreakSeries? selectedBreakSeries,
    List<int>? expandedGroups,
    bool? isAutoAdvancementEnabled,
  }) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      isAutoAdvancementEnabled: isAutoAdvancementEnabled ?? this.isAutoAdvancementEnabled,
    );
  }

  BreakSeries? resolvedBreakSeries(Metadata? metadata) {
    return selectedBreakSeries ?? metadata?.breakSeries;
  }
}
