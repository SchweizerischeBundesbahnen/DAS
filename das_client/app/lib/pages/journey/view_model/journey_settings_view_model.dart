import 'dart:async';
import 'dart:ui';

import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySettingsViewModel extends JourneyAwareViewModel {
  JourneySettingsViewModel({super.journeyTableViewModel});

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

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxSettings.add(
      JourneySettings(initialBreakSeries: journey?.metadata.breakSeries),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _rxSettings.close();
  }
}
