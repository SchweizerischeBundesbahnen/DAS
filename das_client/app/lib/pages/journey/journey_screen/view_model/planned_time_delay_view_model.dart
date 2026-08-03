import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('PlannedTimeDelayViewModel');

/// Calculates the deviation to the planned time (current time - planned arrival time) at each service point.
class PlannedTimeDelayViewModel extends JourneyAwareViewModel {
  PlannedTimeDelayViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    required this._ruFeatureProvider,
    super.journeyViewModel,
  }) {
    _updateFeatureEnabled();
    _positionSubscription = journeyPositionStream.listen(_positionUpdated);
  }

  final RuFeatureProvider _ruFeatureProvider;
  StreamSubscription<JourneyPositionModel>? _positionSubscription;

  bool _hasPassedFirstServicePoint = false;
  bool _isFeatureEnabled = false;

  final _rxModel = BehaviorSubject<Duration?>.seeded(null);

  Stream<Duration?> get model => _rxModel.distinct();

  Duration? get modelValue => _rxModel.value;

  void _positionUpdated(JourneyPositionModel positionModel) {
    _log.fine('Position updated - positionModel: $positionModel');
    if (!_isFeatureEnabled) {
      _log.fine('Feature disabled, emitting null');
      _rxModel.add(null);
      return;
    }

    final currentPosition = positionModel.currentPosition;
    if (currentPosition == positionModel.lastPosition) return;
    if (currentPosition is! ServicePoint) return;

    if (!_hasPassedFirstServicePoint) {
      _log.fine('Position on first service point, emitting null');
      _hasPassedFirstServicePoint = true;
      _rxModel.add(null);
      return;
    }

    final plannedTime = currentPosition.arrivalDepartureTime?.plannedArrivalTime;
    if (plannedTime == null) {
      _log.fine('Service point has no plannedArrivalTime, no emit');
      return;
    }

    final deviation = clock.now().difference(plannedTime);
    _log.fine('Emitting planned time deviation at ${currentPosition.name}: $deviation');
    _rxModel.add(deviation);
  }

  Future<void> _updateFeatureEnabled() async {
    _isFeatureEnabled = await _ruFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.plannedTimeDeviation);
  }

  @override
  void onJourneyChanged(Journey? journey) {
    _hasPassedFirstServicePoint = false;
    _rxModel.add(null);
    _updateFeatureEnabled();
  }

  @override
  void dispose() {
    super.dispose();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _rxModel.close();
  }
}
