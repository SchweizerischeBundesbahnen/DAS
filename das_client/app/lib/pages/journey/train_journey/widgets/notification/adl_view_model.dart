import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/sound/adl_end.dart';
import 'package:app/sound/adl_start.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdlViewModel {
  AdlViewModel({required Stream<Journey?> journeyStream}) {
    _initJourneyStreamSubscription(journeyStream);
  }

  final _adlEndDisplaySeconds = DI.get<TimeConstants>().adlEndDisplaySeconds;

  Timer? _adlEndTimer;

  StreamSubscription<Journey?>? _journeySubscription;

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

  void _initJourneyStreamSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      if (journey != null && journey.metadata.currentPosition != null) {
        final metadata = journey.metadata;
        final activeAdl = metadata.advisedSpeedSegments
            .appliesToOrder(journey.metadata.currentPosition!.order)
            .firstOrNull;

        if (activeAdl != null) {
          if (activeAdlValue == null) {
            // Start of ADL
            AdlStart().play();
          }

          _rxActiveAdl.add(activeAdl);
          _rxAdlState.add(AdlState.active);

          if (activeAdl.endOrder == metadata.currentPosition!.order) {
            // ADL ends at the last position
            _adlEnd(AdlState.end);
          }
        } else if (activeAdlValue != null) {
          // ADL Cancel
          _adlEnd(AdlState.cancel);
        }
      }
    });
  }

  void _adlEnd(AdlState adlState) {
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
