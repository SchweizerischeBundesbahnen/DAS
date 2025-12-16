import 'dart:async';
import 'dart:ui';

import 'package:app/pages/journey/settings/journey_settings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySettingsViewModel {
  JourneySettingsViewModel({required Stream<Journey?> journeyStream}) {
    _initJourneySubscription(journeyStream);
  }

  late StreamSubscription<Journey?>? _journeySubscription;
  TrainIdentification? _lastTrainIdentification;

  final List<VoidCallback> _onBreakSeriesUpdatedCallbacks = [];

  void registerOnBreakSeriesUpdated(VoidCallback callback) {
    _onBreakSeriesUpdatedCallbacks.add(callback);
  }

  void unregisterOnBreakSeriesUpdated(VoidCallback callback) {
    _onBreakSeriesUpdatedCallbacks.remove(callback);
  }

  final _rxSettings = BehaviorSubject<JourneySettings>.seeded(JourneySettings());

  Stream<JourneySettings> get model => _rxSettings.stream;

  JourneySettings get modelValue => _rxSettings.value;

  void updateBreakSeries(BreakSeries selectedBreakSeries) {
    _rxSettings.add(_rxSettings.value.copyWith(selectedBreakSeries: selectedBreakSeries));
    for (final callback in _onBreakSeriesUpdatedCallbacks) {
      callback.call();
    }
  }

  void updateExpandedGroups(List<int> expandedGroups) {
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
