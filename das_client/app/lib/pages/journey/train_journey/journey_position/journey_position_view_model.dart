import 'dart:async';

import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/punctuality/punctuality_model.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyPositionViewModel {
  JourneyPositionViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<PunctualityModel> punctualityStream,
  }) {
    _initSubscription(journeyStream, punctualityStream);
  }

  StreamSubscription<PunctualityModel>? _punctualitySubscription;
  StreamSubscription<(Journey?, PunctualityModel, ServicePoint?)>? _journeySubscription;
  final _rxModel = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

  final _rxNextServicePoint = BehaviorSubject<ServicePoint?>.seeded(null);

  Timer? _servicePointReached;

  JourneyPositionModel get modelValue => _rxModel.value;

  Stream<JourneyPositionModel> get model => _rxModel
      .transform(ThrottleStreamTransformer((_) => TimerStream(null, const Duration(milliseconds: 1))))
      .distinct();

  void dispose() {
    _servicePointReached?.cancel();
    _punctualitySubscription?.cancel();
    _journeySubscription?.cancel();
    _servicePointReached = null;
    _punctualitySubscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream, Stream<PunctualityModel> punctualityStream) {
    _journeySubscription =
        CombineLatestStream.combine3(
          journeyStream,
          punctualityStream,
          _rxNextServicePoint,
          (a, b, c) => (a, b, c),
        ).listen((data) async {
          _servicePointReached?.cancel();

          final journey = data.$1;
          final punctuality = data.$2;

          if (journey == null) return _rxModel.add(JourneyPositionModel());

          final updatedPosition = _calculateCurrentPosition(
            journey.metadata.signaledPosition,
            journey.journeyPoints,
            punctuality,
          );

          _setNextServicePointTimer(updatedPosition, journey.journeyPoints, punctuality);

          final model = JourneyPositionModel(
            currentPosition: updatedPosition,
            lastPosition: _calculateLastPosition(journey),
            previousServicePoint: _calculatePreviousServicePoint(updatedPosition, journey.journeyPoints),
            nextServicePoint: _calculateNextServicePoint(updatedPosition, journey.journeyPoints),
            nextStop: _calculateNextStop(updatedPosition, journey.journeyPoints),
          );

          // makes sure the value is added to the stream before other events received
          await Future.delayed(Duration.zero);
          _rxModel.add(model);
        });
  }

  JourneyPoint? _calculateLastPosition(Journey? journey) {
    final previousModel = _rxModel.value;
    return journey?.journeyPoints.firstWhereOrNull(
      (it) => it.order == previousModel.currentPosition?.order,
    );
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
    punctuality as Visible;

    final nextPointIndex = journeyPoints.indexOf(currentPositionByOrder ?? journeyPoints.first) + 1;

    if (_isEndOfJourney(journeyPoints, nextPointIndex)) return currentPositionByOrder;

    final nextPoint = journeyPoints[nextPointIndex];
    if (nextPoint is! ServicePoint) return currentPositionByOrder;

    final operationalArrivalTime = nextPoint.arrivalDepartureTime?.operationalArrivalTime?.roundDownToTenthOfSecond;
    if (operationalArrivalTime == null) return currentPositionByOrder;

    final trainTime = clock.now().add(punctuality.delay.value);

    if (trainTime.isAfter(operationalArrivalTime)) return nextPoint;

    return currentPositionByOrder;
  }

  bool _isEndOfJourney(List<JourneyPoint> journeyPoints, int nextPointIndex) => journeyPoints.length <= nextPointIndex;

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

  void _setNextServicePointTimer(
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

    final operationalArrivalTime = nextPoint.arrivalDepartureTime?.operationalArrivalTime?.roundDownToTenthOfSecond;
    if (operationalArrivalTime == null) return;

    final trainTime = clock.now().add((punctuality as Visible).delay.value);

    if (trainTime.isAfter(operationalArrivalTime)) return;

    _servicePointReached = Timer(
      operationalArrivalTime.add(Duration(milliseconds: 100)).difference(trainTime),
      () => _rxNextServicePoint.add(nextPoint),
    );
  }
}
