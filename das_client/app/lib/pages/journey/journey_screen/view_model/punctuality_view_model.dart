import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/model/punctuality_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class PunctualityViewModel extends JourneyAwareViewModel {
  PunctualityViewModel({super.journeyTableViewModel}) {
    _initTimers();
  }

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

  @override
  void journeyUpdated(Journey? journey) {
    _journeyUpdated(journey);
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _journeyUpdated(journey);
  }

  void _journeyUpdated(Journey? journey) {
    _updateDelayRelatedStates(journey?.metadata.delay);
    _emitState();
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

  @override
  void dispose() {
    super.dispose();
    _rxModel.close();
    _hiddenTimer?.cancel();
    _staleTimer?.cancel();
  }
}
