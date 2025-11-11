import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_model.dart';
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

  Delay? _delay;

  bool _isStale = false;
  bool _isHiddenDueToNoUpdates = false;

  StreamSubscription<Journey?>? _journeySubscription;

  final _rxModel = BehaviorSubject<PunctualityModel>.seeded(PunctualityModel.hidden());

  Stream<PunctualityModel> get model => _rxModel.distinct();

  PunctualityModel get modelValue => _rxModel.value;

  void dispose() {
    _journeySubscription?.cancel();
    _rxModel.close();
    _hiddenTimer?.cancel();
    _staleTimer?.cancel();
  }

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

  void _initJourneyStreamSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      if (journey == null) return;

      _updateDelayRelatedStates(journey.metadata.delay);

      _emitState();
    });
  }

  void _emitState() {
    if (_isHiddenDueToNoUpdates || _delay == null) return _rxModel.add(PunctualityModel.hidden());
    if (_isStale) return _rxModel.add(PunctualityModel.stale(delay: _delay!));
    _rxModel.add(PunctualityModel.visible(delay: _delay!));
  }

  void _updateDelayRelatedStates(Delay? delay) {
    final isNewDelay = _delay != delay;
    _delay = delay;

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
