import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class PunctualityViewModel {
  PunctualityViewModel({required Stream<Journey?> journeyStream}) {
    _initJourneyStreamSubscription(journeyStream);
    _initTimers();
  }

  final TimeConstants _timeConstants = DI.get<TimeConstants>();

  Timer? _staleTimer;
  Timer? _hiddenTimer;

  Delay? _lastDelay;

  bool _isStale = false;
  bool _isHiddenDueToNoUpdates = false;
  bool _hasCalculatedSpeed = false;

  StreamSubscription<Journey?>? _journeySubscription;

  final _rxPunctualityState = BehaviorSubject<PunctualityState>.seeded(PunctualityState.hidden);

  Stream<PunctualityState> get punctualityState => _rxPunctualityState.distinct();

  PunctualityState get punctualityStateValue => _rxPunctualityState.value;

  void _initTimers() {
    _staleTimer = Timer(Duration(seconds: _timeConstants.punctualityStaleSeconds), () {
      _isStale = true;
      _emitState();
    });
    _hiddenTimer = Timer(Duration(seconds: _timeConstants.punctualityDisappearSeconds), () {
      _isHiddenDueToNoUpdates = true;
      _emitState();
    });
  }

  void _emitState() {
    if (!_hasCalculatedSpeed || _isHiddenDueToNoUpdates) return _rxPunctualityState.add(PunctualityState.hidden);
    if (_isStale) return _rxPunctualityState.add(PunctualityState.stale);
    _rxPunctualityState.add(PunctualityState.visible);
  }

  void dispose() {
    _journeySubscription?.cancel();
    _hiddenTimer?.cancel();
    _staleTimer?.cancel();
  }

  void _initJourneyStreamSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      if (journey == null) return;

      final metadata = journey.metadata;
      _updateDelayRelatedStates(metadata.delay);
      _updateCalculatedSpeedRelatedStates(metadata.lastServicePoint?.calculatedSpeed);

      _emitState();
    });
  }

  void _updateCalculatedSpeedRelatedStates(SingleSpeed? calculatedSpeed) =>
      _hasCalculatedSpeed = calculatedSpeed != null;

  void _updateDelayRelatedStates(Delay? delay) {
    final isNewDelay = delay != _lastDelay;
    _lastDelay = delay;

    if (isNewDelay) {
      _resetTimers();
      _isStale = false;
      _isHiddenDueToNoUpdates = false;
    }
  }

  void _resetTimers() {
    _staleTimer?.cancel();
    _hiddenTimer?.cancel();
    _initTimers();
  }
}
