import 'dart:async';

import 'package:app/time_controller/punctuality_state_enum.dart';
import 'package:sfera/component.dart';

class TimeController {
  final int punctualityStaleSeconds = 3 /*180*/;
  final int punctualityDisappearSeconds = 6 /*300*/;
  final int idleTimeDASModalSheet = 10;
  final int idleTimeAutoScroll = 10;
  DateTime? _lastUpdate;
  Timer? _updateTimer;
  Journey? _lastJourney;
  PunctualityState? _lastEmittedState;
  final _punctualityStateController = StreamController<PunctualityState>.broadcast();
  Stream<PunctualityState> get punctualityStateStream => _punctualityStateController.stream;

  void startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final duration = _lastUpdate != null ? DateTime.now().difference(_lastUpdate!) : Duration.zero;

      final state = _getPunctualityStateFromDuration(duration);
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

  void updatePunctualityTimestamp(Journey? journey) {
    final delay = journey?.metadata.delay;
    if (journey == null || delay == null) return;

    final isNewJourney = journey != _lastJourney;

    _lastJourney = journey;

    if (isNewJourney || _lastUpdate == null) {
      _lastUpdate = DateTime.now();
      _emitState(PunctualityState.visible);
    }
  }

  void _emitState(PunctualityState state) {
    if (state != _lastEmittedState) {
      _punctualityStateController.add(state);
      _lastEmittedState = state;
    }
  }

  void cancelTimer() {
    _updateTimer?.cancel();
  }
}
