import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class PunctualityController {
  final TimeConstants _timeConstants = DI.get<TimeConstants>();

  DateTime? lastUpdate;
  Timer? updateTimer;
  Delay? _lastDelay;

  final _rxPunctualityState = BehaviorSubject<PunctualityState>.seeded(PunctualityState.visible);

  Stream<PunctualityState> get punctualityStateStream => _rxPunctualityState.distinct();

  void startMonitoring() {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = lastUpdate != null ? clock.now().difference(lastUpdate!) : Duration.zero;
      final state = _getPunctualityStateFromDuration(duration);
      _emitState(state);
    });
  }

  PunctualityState _getPunctualityStateFromDuration(Duration duration) {
    if (duration.inSeconds >= _timeConstants.punctualityDisappearSeconds) {
      return PunctualityState.hidden;
    } else if (duration.inSeconds >= _timeConstants.punctualityStaleSeconds) {
      return PunctualityState.stale;
    } else {
      return PunctualityState.visible;
    }
  }

  void updatePunctualityTimestamp(Delay? delay) {
    if (delay == null) return;

    final isNewDelay = delay != _lastDelay;
    _lastDelay = delay;

    if (isNewDelay || lastUpdate == null) {
      lastUpdate = clock.now();
      _emitState(PunctualityState.visible);
    }
  }

  void _emitState(PunctualityState state) {
    _rxPunctualityState.add(state);
  }

  void stopMonitoring() {
    updateTimer?.cancel();
  }
}
