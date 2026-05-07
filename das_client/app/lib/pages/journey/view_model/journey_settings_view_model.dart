import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySettingsViewModel extends JourneyAwareViewModel {
  JourneySettingsViewModel({super.journeyViewModel});

  final _rxSettings = BehaviorSubject<JourneySettings>.seeded(JourneySettings());

  Stream<JourneySettings> get model => _rxSettings.stream;

  JourneySettings get modelValue => _rxSettings.value;

  void updateBrakeSeries(BrakeSeries selectedBrakeSeries) {
    _rxSettings.add(_rxSettings.value.copyWith(selectedBrakeSeries: selectedBrakeSeries));
  }

  void updateExpandedGroups(List<int> expandedGroups) {
    _rxSettings.add(_rxSettings.value.copyWith(expandedGroups: expandedGroups));
  }

  void updateJourneyAdvancement(JourneyAdvancementModel journeyAdvancementModel) {
    _rxSettings.add(_rxSettings.value.copyWith(journeyAdvancementModel: journeyAdvancementModel));
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxSettings.add(
      JourneySettings(initialBrakeSeries: journey?.metadata.brakeSeries),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _rxSettings.close();
  }
}
