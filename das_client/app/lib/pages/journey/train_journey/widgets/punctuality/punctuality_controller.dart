import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class PunctualityController {
  final int punctualityStaleSeconds = 180;

  final int punctualityDisappearSeconds = 300;

  DateTime? lastUpdate;
  Timer? updateTimer;
  Delay? _lastDelay;

  final _punctualityStateController = BehaviorSubject<PunctualityState>.seeded(PunctualityState.visible);

  Stream<PunctualityState> get punctualityStateStream => _punctualityStateController.distinct();

  //todo statt lastupdate und jede sekunde durchgehen eher ein future welches man danach im widget test awaiten kann. (zb future delay) wenn update kommt beide idle times cancellen und wieder neu warten.
  void startMonitoring() {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = lastUpdate != null ? clock.now().difference(lastUpdate!) : Duration.zero;
      final state = _getPunctualityStateFromDuration(duration);
      print('$duration $state');
      _emitState(state);
    });
  }

  PunctualityState _getPunctualityStateFromDuration(Duration duration) {
    if (duration.inSeconds >= punctualityDisappearSeconds) {
      return PunctualityState.hidden;
    } else if (duration.inSeconds >= punctualityStaleSeconds) {
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
    _punctualityStateController.add(state);
  }

  void stopMonitoring() {
    updateTimer?.cancel();
  }
}
