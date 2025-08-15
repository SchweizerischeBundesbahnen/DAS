import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/punctuality/punctuality_model.dart';
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

  StreamSubscription<dynamic>? _subscription;
  final _rxModel = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

  final _rxNextServicePoint = BehaviorSubject<ServicePoint?>.seeded(null);

  Timer? _servicePointReached;

  JourneyPositionModel get modelValue => _rxModel.value;

  Stream<JourneyPositionModel> get model => _rxModel.stream.distinct();

  void dispose() {
    _servicePointReached?.cancel();
    _subscription?.cancel();
    _servicePointReached = null;
    _subscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream, Stream<PunctualityModel> punctualityStream) {
    _subscription =
        CombineLatestStream.combine3(
          journeyStream,
          punctualityStream,
          _rxNextServicePoint,
          (a, b, c) => (a, b, c),
        ).listen((data) {
          final journey = data.$1;
          final punctuality = data.$2;

          _servicePointReached?.cancel();

          // print('Hello\n${journey?.data.length}\n$punctuality');

          if (journey == null) return _rxModel.add(JourneyPositionModel());

          final updatedPosition = _calculateCurrentPosition(
            journey.metadata.signaledPosition,
            journey.journeyPoints,
            punctuality,
          );

          _setTimerIfNextIsServicePoint(updatedPosition, journey.journeyPoints, punctuality);

          final previousModel = _rxModel.value;
          final lastPosition = journey.journeyPoints.firstWhereOrNull(
            (it) => it.order == previousModel.currentPosition?.order,
          );

          final model = JourneyPositionModel(
            currentPosition: updatedPosition,
            lastPosition: lastPosition,
            previousServicePoint: _calculatePreviousServicePoint(updatedPosition, journey.journeyPoints),
            nextServicePoint: _calculateNextServicePoint(updatedPosition, journey.journeyPoints),
            nextStop: _calculateNextStop(updatedPosition, journey.journeyPoints),
          );

          _log.fine(model.lastPosition?.order);

          _rxModel.add(model);
        });
  }

  JourneyPoint? _calculateCurrentPosition(
    SignaledPosition? signaledPosition,
    List<JourneyPoint> journeyPoints,
    PunctualityModel punctuality,
  ) {
    if (journeyPoints.isEmpty) return null;
    if (signaledPosition == null) return journeyPoints.first;

    final currentPositionByOrder = journeyPoints.lastWhereOrNull((it) => it.order <= signaledPosition.order);

    if (currentPositionByOrder is ServicePoint) return currentPositionByOrder;
    if (punctuality is Stale || punctuality is Hidden) return currentPositionByOrder;

    final nextPointIndex = journeyPoints.indexOf(currentPositionByOrder ?? journeyPoints.first) + 1;

    if (_isEndOfJourney(journeyPoints, nextPointIndex)) return currentPositionByOrder;

    final nextPoint = journeyPoints[nextPointIndex];
    if (nextPoint is! ServicePoint) return currentPositionByOrder;

    final operationalArrivalTime = nextPoint.arrivalDepartureTime?.operationalArrivalTime;
    if (operationalArrivalTime == null) return currentPositionByOrder;

    final trainTime = clock.now().add((punctuality as Visible).delay.value);

    if (trainTime.isAfter(operationalArrivalTime)) return nextPoint;

    return currentPositionByOrder;
  }

  bool _isEndOfJourney(List<JourneyPoint> journeyPoints, int nextPointIndex) => journeyPoints.length <= nextPointIndex;

  // static JourneyPoint? _adjustCurrentPositionToServicePoint(
  //   List<JourneyPoint> journeyPoints,
  //   JourneyPoint currentPosition,
  // ) {
  //   final positionIndex = journeyPoints.indexOf(currentPosition);
  //   if (currentPosition is ServicePoint) {
  //     return currentPosition;
  //   }
  //
  //   if (journeyPoints.length > positionIndex + 1) {
  //     final nextData = journeyPoints[positionIndex + 1];
  //     if (nextData is ServicePoint) {
  //       return nextData;
  //     }
  //   }
  //
  //   return currentPosition;
  // }

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

  ServicePoint? _calculateNextStop(JourneyPoint? updatedPosition, List<JourneyPoint> journeyPoints) {
    if (updatedPosition == null) return null;

    return journeyPoints.whereType<ServicePoint>().toList().firstWhereOrNull(
      (sP) => (sP.order > updatedPosition.order) && sP.isStop,
    );
  }

  void _setTimerIfNextIsServicePoint(
    JourneyPoint? updatedPosition,
    List<JourneyPoint> journeyPoints,
    PunctualityModel punctuality,
  ) {
    if (updatedPosition is ServicePoint) return;
    if (punctuality is Stale || punctuality is Hidden) return;

    final nextPointIndex = journeyPoints.indexOf(updatedPosition ?? journeyPoints.first) + 1;

    if (_isEndOfJourney(journeyPoints, nextPointIndex)) return;

    final nextPoint = journeyPoints[nextPointIndex];
    if (nextPoint is! ServicePoint) return;

    final operationalArrivalTime = nextPoint.arrivalDepartureTime?.operationalArrivalTime;
    if (operationalArrivalTime == null) return;

    final trainTime = clock.now().add((punctuality as Visible).delay.value);

    if (trainTime.isAfter(operationalArrivalTime)) return;

    _servicePointReached = Timer(
      operationalArrivalTime.difference(trainTime),
      () => _rxNextServicePoint.add(nextPoint),
    );
  }
}
