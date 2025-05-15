import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ArrivalDepartureTimeViewModel {
  static const int _resetToOperationalAfterSeconds = 10;

  ArrivalDepartureTimeViewModel({required Stream<Journey?> journeyStream}) {
    _listenToJourneyUpdates(journeyStream);
  }

  Stream<bool> get rxShowOperationalTime => _rxShowOperationalTimes.distinct();

  bool get showOperationalTimes => _rxShowOperationalTimes.value;

  late StreamSubscription<Journey?> _journeySubscription;
  bool? _hasJourneyOperationalTimes;
  Timer? _timer;

  final BehaviorSubject<bool> _rxShowOperationalTimes = BehaviorSubject.seeded(true);

  void dispose() {
    _journeySubscription.cancel();
    _timer?.cancel();
    _rxShowOperationalTimes.close();
  }

  void _listenToJourneyUpdates(Stream<Journey?> stream) {
    _journeySubscription = stream.listen((journey) {
      if (journey == null) {
        _rxShowOperationalTimes.add(false);
        _hasJourneyOperationalTimes = null;
        _timer?.cancel();
        return;
      }
      final updatedJourneyHasOpTimes = journey.metadata.anyOperationalArrivalDepartureTimes;
      if (updatedJourneyHasOpTimes != _hasJourneyOperationalTimes) {
        _rxShowOperationalTimes.add(updatedJourneyHasOpTimes);
        _hasJourneyOperationalTimes = updatedJourneyHasOpTimes;
        _timer?.cancel();
      }
    });
  }

  void toggleOperationalTime() {
    if (_hasJourneyOperationalTimes == null || !(_hasJourneyOperationalTimes ?? false)) return;
    final currentValue = _rxShowOperationalTimes.value;
    if (currentValue) {
      _rxShowOperationalTimes.add(false);
      _timer = Timer(Duration(seconds: _resetToOperationalAfterSeconds), () {
        if (!_rxShowOperationalTimes.value) _rxShowOperationalTimes.add(true);
      });
    } else {
      _rxShowOperationalTimes.add(true);
      _timer?.cancel();
    }
  }
}
