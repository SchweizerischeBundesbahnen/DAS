import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('ViewModeViewModel');

class ViewModeViewModel {
  ViewModeViewModel({
    required JourneySettingsViewModel journeySettingsViewModel,
  }) {
    _subscription = journeySettingsViewModel.model.listen((settings) {
      updateZenViewMode(settings.journeyAdvancementModel);
    });
  }

  /// Zen mode will hide the AppBar.
  late final _rxZenViewMode = BehaviorSubject<bool>.seeded(true);
  StreamSubscription? _subscription;

  Stream<bool> get isZenViewMode => _rxZenViewMode.distinct();

  bool get isZenViewModeValue => _rxZenViewMode.value;

  void updateZenViewMode(JourneyAdvancementModel journeyAdvancementModel) {
    final newState = journeyAdvancementModel is! Paused;
    _log.fine('ZenViewMode active: $newState}');
    _rxZenViewMode.add(newState);
  }

  void dispose() {
    _rxZenViewMode.close();
    _subscription?.cancel();
    _subscription = null;
  }
}
