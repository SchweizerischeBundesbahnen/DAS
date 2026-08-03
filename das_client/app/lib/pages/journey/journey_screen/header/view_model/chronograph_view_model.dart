import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/advised_speed_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/delay_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ChronographViewModel extends JourneyAwareViewModel {
  ChronographViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    required Stream<DelayModel> delayStream,
    required Stream<Duration?> plannedTimeDelayStream,
    required Stream<AdvisedSpeedModel> advisedSpeedModelStream,
    required this._calculatedSpeedViewModel,
    super.journeyViewModel,
  }) {
    _initJourneyPositionSubscription(journeyPositionStream);
    _initDelaySubscription(delayStream);
    _initPlannedTimeDelaySubscription(plannedTimeDelayStream);
    _initAdvisedSpeedSubscription(advisedSpeedModelStream);
  }

  final CalculatedSpeedViewModel _calculatedSpeedViewModel;

  bool _isAdvisedSpeedActive = false;
  int? _currentPositionOrder;

  DelayModel _lastDelayModel = DelayModel.hidden();
  Duration? _lastPlannedTimeDelay;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  final _rxModel = BehaviorSubject<DelayModel>.seeded(DelayModel.hidden());

  Stream<DelayModel> get punctualityModel => _rxModel.distinct();

  DelayModel get punctualityModelValue => _rxModel.value;

  Stream<String> get formattedWallclockTime => Stream.periodic(
    const Duration(milliseconds: 200),
    (_) => DateFormat('HH:mm:ss').format(clock.now()),
  ).distinct();

  String get formattedWallclockTimeValue => DateFormat('HH:mm:ss').format(clock.now());

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void _initJourneyPositionSubscription(Stream<JourneyPositionModel> journeyPositionStream) {
    _subscriptions.add(
      journeyPositionStream.listen((model) {
        _currentPositionOrder = model.currentPosition?.order;

        _emitState();
      }),
    );
  }

  void _initDelaySubscription(Stream<DelayModel> punctualityStream) {
    _subscriptions.add(
      punctualityStream.listen((punctualityModel) {
        _lastDelayModel = punctualityModel;

        _emitState();
      }),
    );
  }

  void _initPlannedTimeDelaySubscription(Stream<Duration?> plannedTimeDelayStream) {
    _subscriptions.add(
      plannedTimeDelayStream.listen((plannedTimeDelay) {
        _lastPlannedTimeDelay = plannedTimeDelay;

        _emitState();
      }),
    );
  }

  void _initAdvisedSpeedSubscription(Stream<AdvisedSpeedModel> modelStream) {
    _subscriptions.add(
      modelStream.listen((model) {
        _isAdvisedSpeedActive = model is Active;

        _emitState();
      }),
    );
  }

  void _emitState() {
    if (_isAdvisedSpeedActive) return _rxModel.add(.hidden());

    if (_hasLastServicePointCalculatedSpeed) return _rxModel.add(_lastDelayModel);

    final plannedTimeDelay = _lastPlannedTimeDelay;
    if (plannedTimeDelay != null) {
      return _rxModel.add(.plannedTimeDeviation(deviation: plannedTimeDelay));
    }

    _rxModel.add(.hidden());
  }

  bool get _hasLastServicePointCalculatedSpeed {
    if (_currentPositionOrder == null) return false;
    final calculatedSpeed = _calculatedSpeedViewModel.getCalculatedSpeedForOrder(_currentPositionOrder!);
    return calculatedSpeed.speed != null;
  }

  @override
  void onJourneyUpdated(Journey? _) => _emitState();

  @override
  void onJourneyChanged(_) {
    _lastDelayModel = DelayModel.hidden();
    _lastPlannedTimeDelay = null;
    _rxModel.add(_lastDelayModel);
    _isAdvisedSpeedActive = false;
    _currentPositionOrder = null;
    _emitState();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelSubscriptions();
    _subscriptions.clear();
    _rxModel.close();
  }
}
