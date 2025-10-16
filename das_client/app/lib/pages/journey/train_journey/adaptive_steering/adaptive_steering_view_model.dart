import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/adaptive_steering/adaptive_steering_state.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/sound/adaptive_steering_end.dart';
import 'package:app/sound/adaptive_steering_start.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdaptiveSteeringViewModel {
  AdaptiveSteeringViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel?> journeyPositionStream,
  }) {
    _initJourneyStreamSubscription(journeyStream, journeyPositionStream);
  }

  final _adlEndDisplaySeconds = DI.get<TimeConstants>().adaptiveSteeringEndDisplaySeconds;

  Timer? _adlEndTimer;

  StreamSubscription<(Journey?, JourneyPositionModel?)>? _journeySubscription;

  final _rxActiveAdaptiveSteering = BehaviorSubject<AdvisedSpeedSegment?>.seeded(null);

  Stream<AdvisedSpeedSegment?> get activeAdl => _rxActiveAdaptiveSteering.distinct();

  AdvisedSpeedSegment? get activeAdlValue => _rxActiveAdaptiveSteering.value;

  final _rxAdaptiveSteeringState = BehaviorSubject<AdaptiveSteeringState>.seeded(AdaptiveSteeringState.inactive);

  Stream<AdaptiveSteeringState> get adaptiveSteeringState => _rxAdaptiveSteeringState.distinct();

  AdaptiveSteeringState get adaptiveSteeringStateValue => _rxAdaptiveSteeringState.value;

  void dispose() {
    _journeySubscription?.cancel();
    _rxActiveAdaptiveSteering.close();
    _rxAdaptiveSteeringState.close();
    _adlEndTimer?.cancel();
  }

  void _initJourneyStreamSubscription(
    Stream<Journey?> journeyStream,
    Stream<JourneyPositionModel?> journeyPositionStream,
  ) {
    _journeySubscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((
      data,
    ) {
      final journey = data.$1;
      final journeyPosition = data.$2;

      if (journey != null && journeyPosition?.currentPosition != null) {
        final metadata = journey.metadata;
        final activeAdl = metadata.advisedSpeedSegments
            .appliesToOrder(journeyPosition!.currentPosition!.order)
            .firstOrNull;

        if (activeAdl != null) {
          if (activeAdl.endOrder == journeyPosition.currentPosition!.order) {
            // ADL ends at the last position
            _adlEnd(AdaptiveSteeringState.end);
          } else {
            if (activeAdlValue == null) {
              // Start of ADL
              AdaptiveSteeringStart().play();
            }

            _rxActiveAdaptiveSteering.add(activeAdl);
            _rxAdaptiveSteeringState.add(AdaptiveSteeringState.active);
          }
        } else if (activeAdlValue != null) {
          // ADL Cancel
          _adlEnd(AdaptiveSteeringState.cancel);
        }
      }
    });
  }

  void _adlEnd(AdaptiveSteeringState adlState) {
    if (_rxAdaptiveSteeringState.value != AdaptiveSteeringState.active) return;

    // End of ADL
    _rxActiveAdaptiveSteering.add(null);
    _rxAdaptiveSteeringState.add(adlState);
    AdaptiveSteeringEnd().play();
    _startAdlEndTimer();
  }

  void _startAdlEndTimer() {
    _adlEndTimer?.cancel();
    _adlEndTimer = Timer(Duration(seconds: _adlEndDisplaySeconds), () {
      if (activeAdlValue == null) {
        _rxAdaptiveSteeringState.add(AdaptiveSteeringState.inactive);
      }
    });
  }
}
