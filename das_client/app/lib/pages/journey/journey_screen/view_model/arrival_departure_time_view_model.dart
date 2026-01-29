import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ArrivalDepartureTimeViewModel extends JourneyAwareViewModel {
  final _resetToOperationalAfterSeconds = DI.get<TimeConstants>().arrivalDepartureOperationalResetSeconds;

  ArrivalDepartureTimeViewModel({super.journeyTableViewModel});

  Stream<bool> get showOperationalTime => _rxShowOperationalTimes;

  bool get showOperationalTimeValue => _rxShowOperationalTimes.value;

  Stream<DateTime> get wallclockTimeToMinute => Stream.periodic(
    const Duration(milliseconds: 500),
    (_) => clock.now().roundDownToMinute,
  ).distinct();

  DateTime get wallclockTimeToMinuteValue => clock.now().roundDownToMinute;

  bool? _hasJourneyOperationalTimes;
  Timer? _timer;

  final BehaviorSubject<bool> _rxShowOperationalTimes = BehaviorSubject.seeded(true);

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

  void _journeyUpdated(Journey? journey) {
    if (journey == null) return;

    final updatedJourneyHasOpTimes = journey.metadata.anyOperationalArrivalDepartureTimes;
    if (updatedJourneyHasOpTimes != _hasJourneyOperationalTimes) {
      _rxShowOperationalTimes.add(updatedJourneyHasOpTimes);
      _hasJourneyOperationalTimes = updatedJourneyHasOpTimes;
      _timer?.cancel();
    }
  }

  @override
  void journeyUpdated(Journey? journey) {
    _journeyUpdated(journey);
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxShowOperationalTimes.add(true);
    _hasJourneyOperationalTimes = null;
    _timer?.cancel();
    _journeyUpdated(journey);
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _rxShowOperationalTimes.close();
  }
}
