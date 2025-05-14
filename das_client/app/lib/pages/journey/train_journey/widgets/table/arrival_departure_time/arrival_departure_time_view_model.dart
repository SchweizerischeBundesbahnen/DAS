import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ArrivalDepartureTimeViewModel {
  ArrivalDepartureTimeViewModel({required Stream<Journey?> journeyStream}) {
    _listenToJourneyUpdates(journeyStream);
  }

  Stream<bool> get rxShowCalculatedTimes => _rxShowCalculatedTimes.distinct();

  late StreamSubscription<Journey?> _journeySubscription;

  bool _hasJourneyCalculatedTimes = false;

  final BehaviorSubject<bool> _rxShowCalculatedTimes = BehaviorSubject.seeded(true);

  void dispose() {
    _journeySubscription.cancel();
    _rxShowCalculatedTimes.close();
  }

  void _listenToJourneyUpdates(Stream<Journey?> stream) {
    _journeySubscription = stream.listen((journey) {
      if (journey == null) {
        _rxShowCalculatedTimes.add(false);
        _hasJourneyCalculatedTimes = false;
        return;
      }
      final journeyHasCalculatedTimes = journey.metadata.anyCalculatedArrivalDepartureTimes;
      if (!journeyHasCalculatedTimes) {
        _rxShowCalculatedTimes.add(false);
        _hasJourneyCalculatedTimes = false;
      } else {
        _hasJourneyCalculatedTimes = true;
      }
    });
  }

  void toggleCalculatedTime() {
    if (!_hasJourneyCalculatedTimes) return;
    final currentValue = _rxShowCalculatedTimes.value;
    if (currentValue) {
      _rxShowCalculatedTimes.add(false);
    } else {
      _rxShowCalculatedTimes.add(true);
    }
  }
}
