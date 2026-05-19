import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/punctuality_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('PunctualityViewModel');

class PunctualityViewModel {
  PunctualityViewModel({required JourneyViewModel journeyViewModel}) {
    _initTimers();
    _journeySubscription = journeyViewModel.journey.listen(_journeyUpdated);
  }

  StreamSubscription? _journeySubscription;

  final TimeConstants _timeConstants = DI.get<TimeConstants>();

  Timer? _staleTimer;
  Timer? _hiddenTimer;

  Delay? _delay;

  bool _isStale = false;
  bool _isHiddenDueToNoUpdates = false;

  final _rxModel = BehaviorSubject<PunctualityModel>.seeded(PunctualityModel.hidden());

  Stream<PunctualityModel> get model => _rxModel.distinct();

  PunctualityModel get modelValue => _rxModel.value;

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

  void _journeyUpdated(Journey? journey) {
    _updateDelayRelatedStates(journey?.metadata.delay);
    _emitState();
  }

  void _emitState() {
    if (_isHiddenDueToNoUpdates || _delay == null) {
      _rxModel.add(PunctualityModel.hidden());
    } else if (_isStale) {
      _rxModel.add(PunctualityModel.stale(delay: _delay!));
    } else {
      _rxModel.add(PunctualityModel.visible(delay: _delay!));
    }
    _log.fine('Punctuality state changed to: ${_rxModel.value}');
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

  void dispose() {
    _rxModel.close();
    _hiddenTimer?.cancel();
    _staleTimer?.cancel();
    _journeySubscription?.cancel();
  }
}
