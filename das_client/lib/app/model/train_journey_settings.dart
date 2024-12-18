import 'package:das_client/model/journey/break_series.dart';

class TrainJourneySettings {
  TrainJourneySettings({
    this.selectedBreakSeries,
  });

  final BreakSeries? selectedBreakSeries;

  TrainJourneySettings copyWith({BreakSeries? selectedBreakSeries}) {
    return TrainJourneySettings(
      selectedBreakSeries: selectedBreakSeries ?? this.selectedBreakSeries,
    );
  }
}
