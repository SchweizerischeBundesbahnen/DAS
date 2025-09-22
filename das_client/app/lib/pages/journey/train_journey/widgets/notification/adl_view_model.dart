import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/sound/adl_end.dart';
import 'package:app/sound/adl_start.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdlViewModel {
  AdlViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel?> journeyPositionStream,
  }) {
    _initJourneyStreamSubscription(journeyStream, journeyPositionStream);
  }

  final _adlEndDisplaySeconds = DI.get<TimeConstants>().adlEndDisplaySeconds;

  Timer? _adlEndTimer;

  StreamSubscription<(Journey?, JourneyPositionModel?)>? _journeySubscription;

  final _rxActiveAdl = BehaviorSubject<AdvisedSpeedSegment?>.seeded(null);

  Stream<AdvisedSpeedSegment?> get activeAdl => _rxActiveAdl.distinct();

  AdvisedSpeedSegment? get activeAdlValue => _rxActiveAdl.value;

  final _rxAdlState = BehaviorSubject<AdlState>.seeded(AdlState.inactive);

  Stream<AdlState> get adlState => _rxAdlState.distinct();

  AdlState get adlStateValue => _rxAdlState.value;

  void dispose() {
    _journeySubscription?.cancel();
    _rxActiveAdl.close();
    _rxAdlState.close();
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
            _adlEnd(AdlState.end);
          } else {
            if (activeAdlValue == null) {
              // Start of ADL
              AdlStart().play();
            }

            _rxActiveAdl.add(activeAdl);
            _rxAdlState.add(AdlState.active);
          }
        } else if (activeAdlValue != null) {
          // ADL Cancel
          _adlEnd(AdlState.cancel);
        }
      }
    });
  }

  void _adlEnd(AdlState adlState) {
    if (_rxAdlState.value != AdlState.active) return;

    // End of ADL
    _rxActiveAdl.add(null);
    _rxAdlState.add(adlState);
    AdlEnd().play();
    _startAdlEndTimer();
  }

  void _startAdlEndTimer() {
    _adlEndTimer?.cancel();
    _adlEndTimer = Timer(Duration(seconds: _adlEndDisplaySeconds), () {
      if (activeAdlValue == null) {
        _rxAdlState.add(AdlState.inactive);
      }
    });
  }
}

enum AdlState {
  active,
  inactive,
  end,
  cancel,
}
