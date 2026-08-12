import 'dart:async';

import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/delay_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/provider/timed_route_provider.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyPositionViewModel');

class JourneyPositionViewModel extends JourneyAwareViewModel {
  JourneyPositionViewModel({
    required Stream<DelayModel> punctualityStream,
    required super.journeyViewModel,
    required this._journeySettingsViewModel,
    required this._timedRouteProvider,
  }) {
    _initSubscription(journeyViewModel.journey, punctualityStream);
  }

  final JourneySettingsViewModel _journeySettingsViewModel;
  final TimedRouteProvider _timedRouteProvider;

  StreamSubscription<(Journey?, DelayModel, ServicePoint?, JourneyPoint?)>? _journeySubscription;
  final _rxModel = BehaviorSubject.seeded(JourneyPositionModel());

  final _rxTimedServicePointReached = BehaviorSubject<ServicePoint?>.seeded(null);
  Timer? _servicePointReachedTimer;

  final _rxManualPosition = BehaviorSubject<JourneyPoint?>.seeded(null);
  DateTime? _manualPositionTime;
  Timer? _manuelPositionAdvancementTimer;
  SignaledPosition? _lastSignaledPosition;

  Stream<JourneyPositionModel> get model => _rxModel.distinct();

  JourneyPositionModel get modelValue => _rxModel.value;

  void setManualPosition(JourneyPoint? manualPosition) {
    _log.info('Setting manual position to: $manualPosition');
    _rxManualPosition.add(manualPosition);
    _manualPositionTime = clock.now();
    _manuelPositionAdvancementTimer?.cancel();
    if (manualPosition is ServicePoint) {
      _startManualPositionTimer(manualPosition);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _journeySubscription?.cancel();
    _rxModel.close();
    _rxTimedServicePointReached.close();
    _rxManualPosition.close();
    _servicePointReachedTimer?.cancel();
    _servicePointReachedTimer = null;
    _manuelPositionAdvancementTimer?.cancel();
    _manuelPositionAdvancementTimer = null;
  }

  void _startManualPositionTimer(ServicePoint manualPosition) {
    final arrivalTime = manualPosition.arrivalDepartureTime?.bestKnownArrivalTime;
    final manualPositionTime = _manualPositionTime;
    final nextServicePoint = lastJourney?.journeyPoints.whereType<ServicePoint>().firstWhereOrNull(
      (it) => it.order > manualPosition.order,
    );
    final nextArrivalTime = nextServicePoint?.arrivalDepartureTime?.bestKnownArrivalTime;
    if (arrivalTime != null && manualPositionTime != null && nextArrivalTime != null) {
      final timeSinceArrival = manualPositionTime.difference(arrivalTime);
      final nextServicePointDuration = nextArrivalTime.add(timeSinceArrival).difference(clock.now());
      _log.info(
        'Time since arrival $timeSinceArrival. Scheduling manual advancement in $nextServicePointDuration to ${nextServicePoint?.name}',
      );
      _manuelPositionAdvancementTimer = Timer(nextServicePointDuration, () {
        if (_journeySettingsViewModel.modelValue.journeyAdvancementModel.isInManualCycle) {
          _log.info('Manual position timer expired, advancing to next service point');
          setManualPosition(nextServicePoint);
        }
      });
    }
  }

  JourneyAdvancementModel get _currentAdvancementMode => _journeySettingsViewModel.modelValue.journeyAdvancementModel;

  void _initSubscription(Stream<Journey?> journeyStream, Stream<DelayModel> punctualityStream) {
    _journeySubscription =
        CombineLatestStream.combine4(
          journeyStream,
          punctualityStream,
          _rxTimedServicePointReached.distinct(),
          _rxManualPosition,
          (a, b, c, d) => (a, b, c, d),
        ).listen((data) async {
          _servicePointReachedTimer?.cancel();

          _log.fine('Position update triggered');

          final journey = data.$1;
          final punctuality = data.$2;

          if (journey == null) return;

          _resetAdvancementOnNewSignaledPosition(journey.metadata.signaledPosition);

          final updatedPosition = _calculateCurrentPosition(
            journey.metadata.signaledPosition,
            journey.journeyPoints,
          );

          _calculateAndSetTimedServicePoint(updatedPosition, journey, punctuality);

          final calculatedLastPosition = _calculateLastPosition(journey, updatedPosition);
          final lastPosition = calculatedLastPosition == updatedPosition
              ? _rxModel.value.lastPosition
              : calculatedLastPosition;

          final model = JourneyPositionModel(
            currentPosition: updatedPosition,
            lastPosition: lastPosition,
            previousServicePoint: _calculatePreviousServicePoint(updatedPosition, journey.journeyPoints),
            nextServicePoint: _calculateNextServicePoint(updatedPosition, journey.journeyPoints),
            previousStop: _calculatePreviousStop(updatedPosition, journey.journeyPoints),
            nextStop: _calculateNextStop(updatedPosition, journey.journeyPoints),
            isManualPosition: _isManualPosition(updatedPosition),
          );

          if (!_rxModel.isClosed) _rxModel.add(model);
        });
  }

  /// A signal advancement has priority over any timed or manual advancement, even if those
  /// have already advanced further along the route.
  void _resetAdvancementOnNewSignaledPosition(SignaledPosition? signaledPosition) {
    final isNewSignaledPosition = signaledPosition != null && signaledPosition != _lastSignaledPosition;
    _lastSignaledPosition = signaledPosition;
    if (!isNewSignaledPosition) return;

    _manuelPositionAdvancementTimer?.cancel();
    _manualPositionTime = null;
    if (_rxManualPosition.value != null) _rxManualPosition.add(null);
    if (_rxTimedServicePointReached.value != null) _rxTimedServicePointReached.add(null);
  }

  JourneyPoint? _calculateLastPosition(Journey? journey, JourneyPoint? updatedPosition) {
    final previousModel = _rxModel.valueOrNull;
    final previousPosition = previousModel?.currentPosition;
    if (journey == null || previousPosition == null) return null;

    final previousJourneyPointIndex = journey.journeyPoints.indexOf(previousPosition);
    if (previousJourneyPointIndex != -1) {
      return journey.journeyPoints.elementAt(previousJourneyPointIndex);
    } else {
      return _calculatePositionByOrder(journey.journeyPoints, previousPosition.order);
    }
  }

  JourneyPoint? _calculatePositionByOrder(List<JourneyPoint> journeyPoints, int order) {
    JourneyPoint? position;
    final possiblePositions = journeyPoints.where((it) => it.order == order).toList();
    // Prefer Signals over other elements
    position ??= possiblePositions.whereType<Signal>().firstOrNull;
    position ??= possiblePositions.firstOrNull;
    return position;
  }

  JourneyPoint? _calculateCurrentPosition(
    SignaledPosition? signaledPosition,
    List<JourneyPoint> journeyPoints,
  ) {
    if (journeyPoints.isEmpty) return null;
    if (signaledPosition == null && _rxManualPosition.value == null && _rxTimedServicePointReached.value == null) {
      return journeyPoints.first;
    }

    JourneyPoint? currentPosition;
    final signaledPositionOrder = signaledPosition?.order ?? -1;
    final currentPositionOrder = journeyPoints.lastWhereOrNull((it) => it.order <= (signaledPositionOrder))?.order;
    if (currentPositionOrder != null) {
      currentPosition = _calculatePositionByOrder(journeyPoints, currentPositionOrder);
    }

    final timedServicePoint = _rxTimedServicePointReached.value;
    if (timedServicePoint != null && (currentPosition == null || timedServicePoint.order > currentPosition.order)) {
      currentPosition = timedServicePoint;
    }

    final manualPosition = _rxManualPosition.value;
    if (manualPosition != null && _currentAdvancementMode.isInManualCycle) {
      currentPosition = _rxManualPosition.value;
    }

    return currentPosition;
  }

  ServicePoint? _calculatePreviousServicePoint(
    JourneyPoint? updatedPosition,
    List<JourneyPoint> journeyPoints,
  ) {
    if (updatedPosition == null) return null;

    return journeyPoints.whereType<ServicePoint>().toList().reversed.firstWhereOrNull(
      (sP) => sP.order <= updatedPosition.order,
    );
  }

  ServicePoint? _calculateNextServicePoint(
    JourneyPoint? updatedPosition,
    List<JourneyPoint> journeyPoints,
  ) {
    if (updatedPosition == null) return null;

    return journeyPoints.whereType<ServicePoint>().toList().firstWhereOrNull(
      (sP) => sP.order > updatedPosition.order,
    );
  }

  ServicePoint? _calculatePreviousStop(JourneyPoint? updatedPosition, List<JourneyPoint> journeyPoints) {
    if (updatedPosition == null) return null;

    return journeyPoints.whereType<ServicePoint>().toList().reversed.firstWhereOrNull(
      (sP) => sP.order <= updatedPosition.order && sP.isStop,
    );
  }

  ServicePoint? _calculateNextStop(JourneyPoint? updatedPosition, List<JourneyPoint> journeyPoints) {
    if (updatedPosition == null) return null;

    return journeyPoints.whereType<ServicePoint>().toList().firstWhereOrNull(
      (sP) => (sP.order > updatedPosition.order) && sP.isStop,
    );
  }

  void _calculateAndSetTimedServicePoint(
    JourneyPoint? updatedPosition,
    Journey journey,
    DelayModel punctuality,
  ) {
    if (_timedRouteProvider.isInTimedAdvancementRoute(updatedPosition, journey.journeyPoints)) {
      _log.info('Journey is in timed advancement route');
      _handleTimedRoute(updatedPosition!, journey.journeyPoints);
    } else {
      _handleSignaledRoute(updatedPosition, journey, punctuality);
    }
  }

  void _handleSignaledRoute(
    JourneyPoint? updatedPosition,
    Journey journey,
    DelayModel punctuality,
  ) {
    if (updatedPosition is ServicePoint) return;

    final journeyPoints = journey.journeyPoints;
    if (journeyPoints.isEmpty) return;

    final nextPointIndex = journeyPoints.indexOf(updatedPosition ?? journeyPoints.first) + 1;

    JourneyPoint? nextPoint;
    for (var i = nextPointIndex; i < journeyPoints.length - 1; i++) {
      nextPoint = journeyPoints[i];

      // Cancel when we have a signal before the next service point
      if (nextPoint is Signal) return;

      // found next service point
      if (nextPoint is ServicePoint) break;
    }

    if (nextPoint is! ServicePoint) return;

    final nextServicePoint = nextPoint;

    final bestKnownArrivalTime = nextServicePoint.arrivalDepartureTime?.bestKnownArrivalTime?.roundDownToTenthOfSecond;
    if (bestKnownArrivalTime == null) return;

    final DateTime arrivalTime;
    if (journey.metadata.calculatedSpeeds[nextServicePoint.order] != null) {
      // with VPro speeds the PüA drives the advancement, wait for the next signal on stale or missing PüA
      if (punctuality is! Visible) return;
      arrivalTime = bestKnownArrivalTime.add(punctuality.delay.value);
    } else {
      // no VPro => no PüA to consider
      arrivalTime = bestKnownArrivalTime;
    }

    final now = clock.now();
    final untilNextServicePoint = arrivalTime.add(Duration(milliseconds: 50)).difference(now);
    _setTimedServicePoint(durationUntilNextServicePoint: untilNextServicePoint, nextServicePoint: nextServicePoint);
  }

  void _handleTimedRoute(JourneyPoint updatedPosition, List<JourneyPoint> journeyPoints) {
    final nextTimedServicePoint = _timedRouteProvider.calculateNextTimedServicePoint(updatedPosition, journeyPoints);
    if (nextTimedServicePoint != null) {
      final (durationUntilNextServicePoint, nextServicePoint) = nextTimedServicePoint;
      _setTimedServicePoint(
        durationUntilNextServicePoint: durationUntilNextServicePoint,
        nextServicePoint: nextServicePoint,
      );
    }
  }

  void _setTimedServicePoint({
    required Duration durationUntilNextServicePoint,
    required ServicePoint nextServicePoint,
  }) {
    final now = clock.now();
    if (durationUntilNextServicePoint.inMilliseconds <= 0) {
      _log.info('Setting timed service point immediately to ${nextServicePoint.name}');
      _rxTimedServicePointReached.add(nextServicePoint);
    } else {
      final arrivalTime = now.add(durationUntilNextServicePoint);
      _log.info('Scheduling timed service point for ${nextServicePoint.name} at $arrivalTime');
      _servicePointReachedTimer = Timer(
        durationUntilNextServicePoint,
        () {
          _log.info('Setting timed service point to ${nextServicePoint.name}');
          if (!_rxTimedServicePointReached.isClosed) _rxTimedServicePointReached.add(nextServicePoint);
        },
      );
    }
  }

  bool _isManualPosition(JourneyPoint? updatedPosition) {
    return _rxManualPosition.valueOrNull != null &&
        updatedPosition == _rxManualPosition.value &&
        _currentAdvancementMode.isInManualCycle;
  }
}
