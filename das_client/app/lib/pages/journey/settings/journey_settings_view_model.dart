import 'dart:async';
import 'dart:ui';

import 'package:app/pages/journey/settings/journey_settings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySettingsViewModel {
  JourneySettingsViewModel({required Stream<Journey?> journeyStream, required VoidCallback onBreakSeriesUpdated}) {
    _onBreakSeriesUpdated = onBreakSeriesUpdated;
    _initJourneySubscription(journeyStream);
  }

  late StreamSubscription<Journey?>? _journeySubscription;
  TrainIdentification? _lastTrainIdentification;

  late VoidCallback _onBreakSeriesUpdated;

  final _rxSettings = BehaviorSubject<JourneySettings>.seeded(JourneySettings());

  Stream<JourneySettings> get model => _rxSettings.stream;

  JourneySettings get modelValue => _rxSettings.value;

  void onBreakSeriesChanged(BreakSeries selectedBreakSeries) {
    _rxSettings.add(_rxSettings.value.copyWith(selectedBreakSeries: selectedBreakSeries));
    _onBreakSeriesUpdated.call();
  }

  void onExpandedGroupsChanged(List<int> expandedGroups) {
    _rxSettings.add(_rxSettings.value.copyWith(expandedGroups: expandedGroups));
  }

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }

  void _initJourneySubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((data) {
      if (data == null || data.metadata.trainIdentification != _lastTrainIdentification) {
        _lastTrainIdentification = data?.metadata.trainIdentification;
        _rxSettings.add(JourneySettings());
      }
    });
  }
}
