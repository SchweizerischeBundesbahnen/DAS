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

  StreamSubscription<DelayModel>? _punctualitySubscription;
  StreamSubscription<(Journey?, DelayModel, ServicePoint?, JourneyPoint?)>? _journeySubscription;
  final _rxModel = BehaviorSubject.seeded(JourneyPositionModel());

  final _rxTimedServicePointReached = BehaviorSubject<ServicePoint?>.seeded(null);
  Timer? _servicePointReachedTimer;

  final _rxManualPosition = BehaviorSubject<JourneyPoint?>.seeded(null);
  DateTime? _manualPositionTime;
  Timer? _manuelPositionAdvancementTimer;

  Stream<JourneyPositionModel> get model => _rxModel.distinct();

  JourneyPositionModel get modelValue => _rxModel.value;

  void setManualPosition(JourneyPoint? manualPosition) {
    _log.info('Setting manual position to: $manualPosition');
    _rxManualPosition.add(manualPosition);
    _manualPositionTime = clock.now();
    if (manualPosition != null && manualPosition is ServicePoint) {
      _startManualPositionTimer(manualPosition);
    }
  }

  void _startManualPositionTimer(ServicePoint manualPosition) {
    _manuelPositionAdvancementTimer?.cancel();

    final arrivalTime = manualPosition.arrivalDepartureTime?.plannedArrivalTime;
    final manualPositionTime = _manualPositionTime;
    final nextServicePoint = lastJourney?.journeyPoints.whereType<ServicePoint>().firstWhereOrNull(
      (it) => it.order > manualPosition.order,
    );
    final nextArrivalTime = nextServicePoint?.arrivalDepartureTime?.plannedArrivalTime;
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

          _log.info('Position update triggered');

          final journey = data.$1;
          final punctuality = data.$2;

          if (journey == null) {
            return;
          }

          final (updatedPosition, isManualPosition) = _calculateCurrentPosition(
            journey.metadata.signaledPosition,
            journey.journeyPoints,
          );

          _calculateAndSetTimedServicePoint(updatedPosition, journey.journeyPoints, punctuality);

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
            isManualPosition: isManualPosition,
          );

          if (!_rxModel.isClosed) {
            _rxModel.add(model);
          }
        });
  }

  JourneyPoint? _calculateLastPosition(Journey? journey, JourneyPoint? updatedPosition) {
    final previousModel = _rxModel.valueOrNull;
    final previousPosition = previousModel?.currentPosition;
    final journeyStart = journey?.data.whereType<JourneyPoint>().firstOrNull;
    if (journey == null || previousPosition == null || journeyStart == updatedPosition) return null;

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

  /// Calculates the current position based on the signaled position, manual position, and timed service point.
  /// Returns a tuple of the current position and a boolean indicating whether the position is manual.
  (JourneyPoint?, bool) _calculateCurrentPosition(
    SignaledPosition? signaledPosition,
    List<JourneyPoint> journeyPoints,
  ) {
    bool isManualPosition = false;

    if (journeyPoints.isEmpty) return (null, isManualPosition);
    if (signaledPosition == null && _rxManualPosition.value == null && _rxTimedServicePointReached.value == null) {
      return (journeyPoints.first, isManualPosition);
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
      isManualPosition = true;
    }

    return (currentPosition, isManualPosition);
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
    List<JourneyPoint> journeyPoints,
    DelayModel punctuality,
  ) {
    if (_timedRouteProvider.isInTimedAdvancementRoute(updatedPosition, journeyPoints)) {
      _log.info('Journey is in timed advancement route');
      _handleTimedRoute(updatedPosition!, journeyPoints);
    } else {
      _handleSignaledRoute(updatedPosition, journeyPoints, punctuality);
    }
  }

  void _handleSignaledRoute(
    JourneyPoint? updatedPosition,
    List<JourneyPoint> journeyPoints,
    DelayModel punctuality,
  ) {
    if (punctuality is Stale || punctuality is Hidden) return;
    if (updatedPosition is ServicePoint) return;

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

    final operationalArrivalTime =
        nextServicePoint.arrivalDepartureTime?.operationalArrivalTime?.roundDownToTenthOfSecond;
    if (operationalArrivalTime == null) return;

    final arrivalTimeWithDelay = operationalArrivalTime.add((punctuality as Visible).delay.value);

    final now = clock.now();
    final untilNextServicePoint = arrivalTimeWithDelay.add(Duration(milliseconds: 100)).difference(now);
    _setTimedServicePoint(untilNextServicePoint, nextServicePoint);
  }

  void _handleTimedRoute(JourneyPoint updatedPosition, List<JourneyPoint> journeyPoints) {
    final nextTimedServicePoint = _timedRouteProvider.calculateNextTimedServicePoint(updatedPosition, journeyPoints);
    if (nextTimedServicePoint != null) {
      final (secondsUntilNextServicePoint, nextServicePoint) = nextTimedServicePoint;
      _setTimedServicePoint(secondsUntilNextServicePoint, nextServicePoint);
    }
  }

  void _setTimedServicePoint(Duration nextServicePointDuration, ServicePoint nextServicePoint) {
    final now = clock.now();
    if (nextServicePointDuration.inMilliseconds <= 0) {
      _log.info('Setting timed service point immediately to ${nextServicePoint.name}');
      _rxTimedServicePointReached.add(nextServicePoint);
    } else {
      final arrivalTime = now.add(nextServicePointDuration);
      _log.info('Scheduling timed service point for ${nextServicePoint.name} at $arrivalTime');
      _servicePointReachedTimer = Timer(
        nextServicePointDuration,
        () {
          _log.info('Setting timed service point to ${nextServicePoint.name}');
          _rxTimedServicePointReached.add(nextServicePoint);
        },
      );
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
    _punctualitySubscription?.cancel();
    _punctualitySubscription = null;
  }
}
