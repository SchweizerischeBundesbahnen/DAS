import 'dart:async';

import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_model.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyPositionViewModel');

class JourneyPositionViewModel {
  JourneyPositionViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<PunctualityModel> punctualityStream,
  }) {
    _initSubscription(journeyStream, punctualityStream);
  }

  StreamSubscription<PunctualityModel>? _punctualitySubscription;
  StreamSubscription<(Journey?, PunctualityModel, ServicePoint?, JourneyPoint?)>? _journeySubscription;
  final _rxModel = BehaviorSubject.seeded(JourneyPositionModel());

  final _rxTimedServicePointReached = BehaviorSubject<ServicePoint?>.seeded(null);
  ServicePoint? _lastTimedServicePoint;
  Timer? _servicePointReachedTimer;

  final _rxManualPosition = BehaviorSubject<JourneyPoint?>.seeded(null);
  JourneyPoint? _lastManualPosition;

  TrainIdentification? _lastTrainIdentification;

  Stream<JourneyPositionModel> get model => _rxModel.distinct();

  JourneyPositionModel get modelValue => _rxModel.value;

  void setManualPosition(JourneyPoint? manualPosition) {
    _log.fine('Setting manual position to: $manualPosition');
    _rxManualPosition.add(manualPosition);
  }

  void dispose() {
    _journeySubscription?.cancel();
    _rxModel.close();
    _rxTimedServicePointReached.close();
    _rxManualPosition.close();
    _servicePointReachedTimer?.cancel();
    _servicePointReachedTimer = null;
    _punctualitySubscription?.cancel();
    _punctualitySubscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream, Stream<PunctualityModel> punctualityStream) {
    _journeySubscription =
        CombineLatestStream.combine4(
          journeyStream,
          punctualityStream,
          _rxTimedServicePointReached,
          _rxManualPosition,
          (a, b, c, d) => (a, b, c, d),
        ).listen((data) async {
          _servicePointReachedTimer?.cancel();

          final journey = data.$1;
          final punctuality = data.$2;

          if (journey == null) {
            _rxModel.add(JourneyPositionModel());
            return;
          }

          if (_lastTrainIdentification != journey.metadata.trainIdentification) {
            // Reset timed service point when train identification changes
            _rxTimedServicePointReached.add(null);
            _lastTrainIdentification = journey.metadata.trainIdentification;
            return;
          }

          final updatedPosition = _calculateCurrentPosition(
            journey.metadata.signaledPosition,
            journey.journeyPoints,
            punctuality,
          );

          _setTimedServicePoint(updatedPosition, journey.journeyPoints, punctuality);

          final model = JourneyPositionModel(
            currentPosition: updatedPosition,
            lastPosition: _calculateLastPosition(journey),
            previousServicePoint: _calculatePreviousServicePoint(updatedPosition, journey.journeyPoints),
            nextServicePoint: _calculateNextServicePoint(updatedPosition, journey.journeyPoints),
            previousStop: _calculatePreviousStop(updatedPosition, journey.journeyPoints),
            nextStop: _calculateNextStop(updatedPosition, journey.journeyPoints),
          );

          // delay position update, so journey is processed first (animation will jump otherwise)
          await Future.delayed(Duration(milliseconds: 2));
          if (!_rxModel.isClosed) {
            _rxModel.add(model);
          }
        });
  }

  JourneyPoint? _calculateLastPosition(Journey? journey) {
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
    PunctualityModel punctuality,
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
    if (_lastTimedServicePoint != timedServicePoint && timedServicePoint != null) {
      _lastTimedServicePoint = timedServicePoint;
      currentPosition = _lastTimedServicePoint;
    }

    final manualPosition = _rxManualPosition.value;
    if (_lastManualPosition != manualPosition && manualPosition != null) {
      _lastManualPosition = _rxManualPosition.value;
      currentPosition = _lastManualPosition;
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

  void _setTimedServicePoint(
    JourneyPoint? updatedPosition,
    List<JourneyPoint> journeyPoints,
    PunctualityModel punctuality,
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

    if (now.isAfter(arrivalTimeWithDelay)) {
      _log.info('Setting timed service point immediately to ${nextServicePoint.name}');
      _rxTimedServicePointReached.add(nextServicePoint);
    } else {
      _log.info('Scheduling timed service point for ${nextServicePoint.name} at $arrivalTimeWithDelay');
      _servicePointReachedTimer = Timer(
        arrivalTimeWithDelay.add(Duration(milliseconds: 100)).difference(now),
        () {
          _log.info('Setting timed service point to ${nextServicePoint.name}');
          _rxTimedServicePointReached.add(nextServicePoint);
        },
      );
    }
  }
}
