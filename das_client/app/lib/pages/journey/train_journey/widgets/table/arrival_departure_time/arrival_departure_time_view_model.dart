import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ArrivalDepartureTimeViewModel {
  ArrivalDepartureTimeViewModel({required Stream<Journey?> journeyStream}) {
    _listenToJourneyUpdates(journeyStream);
  }

  late StreamSubscription<Journey?> _journeySubscription;

  bool _hasJourneyCalculatedTimes = false;

  final BehaviorSubject<bool> rxShowCalculatedTimes = BehaviorSubject.seeded(true);

  void dispose() {
    _journeySubscription.cancel();
    rxShowCalculatedTimes.close();
  }

  void _listenToJourneyUpdates(Stream<Journey?> stream) {
    _journeySubscription = stream.listen((journey) {
      if (journey == null) {
        rxShowCalculatedTimes.add(false);
        _hasJourneyCalculatedTimes = false;
        return;
      }
      final journeyHasCalculatedTimes = journey.metadata.hasAnyCalculatedTimes;
      if (!journeyHasCalculatedTimes) {
        rxShowCalculatedTimes.add(false);
        _hasJourneyCalculatedTimes = false;
      } else {
        rxShowCalculatedTimes.add(true);
        _hasJourneyCalculatedTimes = true;
      }
    });
  }

  void toggleCalculatedTime() {
    if (!_hasJourneyCalculatedTimes) return;
    final currentValue = rxShowCalculatedTimes.value;
    if (currentValue) {
      rxShowCalculatedTimes.add(false);
    } else {
      rxShowCalculatedTimes.add(true);
    }
  }
}
