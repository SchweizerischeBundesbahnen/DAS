import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/widgets/chronograph/punctuality_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ChronographViewModel {
  static const String trainIsPunctualString = '+00:00';

  ChronographViewModel({required Stream<Journey?> journeyStream}) {
    _initJourneyStreamSubscription(journeyStream);
    _initTimers();
  }

  final TimeConstants _timeConstants = DI.get<TimeConstants>();

  Timer? _staleTimer;
  Timer? _hiddenTimer;

  String _currentDelayString = '';
  Delay? _delay;

  bool _isStale = false;
  bool _isHiddenDueToNoUpdates = false;
  bool _hasCalculatedSpeed = false;

  StreamSubscription<Journey?>? _journeySubscription;

  final _rxModel = BehaviorSubject<PunctualityModel>.seeded(PunctualityModel.hidden());

  Stream<PunctualityModel> get punctualityModel => _rxModel.distinct();

  PunctualityModel get punctualityModelValue => _rxModel.value;

  Stream<DateTime> get wallclockTime => Stream.periodic(const Duration(milliseconds: 200), (_) => clock.now());

  Stream<String> get formattedWallclockTime => wallclockTime.map(DateFormat('HH:mm:ss').format);

  String get formattedWallclockTimeValue => DateFormat('HH:mm:ss').format(clock.now());

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
    if (!_hasCalculatedSpeed || _isHiddenDueToNoUpdates) return _rxModel.add(PunctualityModel.hidden());
    if (_isStale) return _rxModel.add(PunctualityModel.stale(delay: _currentDelayString));
    _rxModel.add(PunctualityModel.visible(delay: _currentDelayString));
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
    final isNewDelay = _delay != delay;
    final String stringDelay = _stringDelayPresentation(delay);
    _delay = delay;
    _currentDelayString = stringDelay;

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

  String _stringDelayPresentation(Delay? delay) {
    if (delay == null) return '';

    final d = delay.value;

    final minutes = NumberFormat('00').format(d.inMinutes.abs());
    final seconds = NumberFormat('00').format(d.inSeconds.abs() % 60);
    return '${d.isNegative ? '-' : '+'}$minutes:$seconds';
  }
}
