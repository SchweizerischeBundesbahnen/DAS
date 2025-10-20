import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_model.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_state.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/sound/advised_speed_end.dart';
import 'package:app/sound/advised_speed_start.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedViewModel {
  AdvisedSpeedViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel?> journeyPositionStream,
  }) {
    _initJourneyStreamSubscription(journeyStream, journeyPositionStream);
  }

  final _adlEndDisplaySeconds = DI.get<TimeConstants>().advisedSpeedEndDisplaySeconds;

  Timer? _adlEndTimer;

  StreamSubscription<(Journey?, JourneyPositionModel?)>? _journeySubscription;

  final _rxActiveAdvisedSpeed = BehaviorSubject<AdvisedSpeedSegment?>.seeded(null);

  final _rxModel = BehaviorSubject<AdvisedSpeedModel>.seeded(AdvisedSpeedModel.inactive());

  Stream<AdvisedSpeedSegment?> get activeAdl => _rxActiveAdvisedSpeed.distinct();

  AdvisedSpeedSegment? get activeAdlValue => _rxActiveAdvisedSpeed.value;

  final _rxAdvisedSpeedState = BehaviorSubject<AdvisedSpeedState>.seeded(AdvisedSpeedState.inactive);

  Stream<AdvisedSpeedState> get advisedSpeedState => _rxAdvisedSpeedState.distinct();

  Stream<AdvisedSpeedModel> get model => _rxModel.distinct();

  AdvisedSpeedModel get modelValue => _rxModel.value;

  AdvisedSpeedState get advisedSpeedStateValue => _rxAdvisedSpeedState.value;

  void dispose() {
    _journeySubscription?.cancel();
    _rxActiveAdvisedSpeed.close();
    _rxAdvisedSpeedState.close();
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
            _adlEnd(AdvisedSpeedState.end);
          } else {
            if (activeAdlValue == null) {
              // Start of ADL
              AdvisedSpeedStart().play();
            }

            _rxActiveAdvisedSpeed.add(activeAdl);
            _rxAdvisedSpeedState.add(AdvisedSpeedState.active);
          }
        } else if (activeAdlValue != null) {
          // ADL Cancel
          _adlEnd(AdvisedSpeedState.cancel);
        }
      }
    });
  }

  void _adlEnd(AdvisedSpeedState adlState) {
    if (_rxAdvisedSpeedState.value != AdvisedSpeedState.active) return;

    // End of ADL
    _rxActiveAdvisedSpeed.add(null);
    _rxAdvisedSpeedState.add(adlState);
    AdvisedSpeedEnd().play();
    _startAdlEndTimer();
  }

  void _startAdlEndTimer() {
    _adlEndTimer?.cancel();
    _adlEndTimer = Timer(Duration(seconds: _adlEndDisplaySeconds), () {
      if (activeAdlValue == null) {
        _rxAdvisedSpeedState.add(AdvisedSpeedState.inactive);
      }
    });
  }
}
