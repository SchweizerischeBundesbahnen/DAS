import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ArrivalDepartureTimeViewModel {
  final _resetToOperationalAfterSeconds = DI.get<TimeConstants>().arrivalDepartureOperationalResetSeconds;

  ArrivalDepartureTimeViewModel({required Stream<Journey?> journeyStream}) {
    _listenToJourneyUpdates(journeyStream);
  }

  Stream<bool> get showOperationalTime => _rxShowOperationalTimes.distinct();

  bool get showOperationalTimeValue => _rxShowOperationalTimes.value;

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
