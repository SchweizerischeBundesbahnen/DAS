import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyPositionViewModel {
  JourneyPositionViewModel({required Stream<Journey?> journeyStream}) {
    _initSubscription(journeyStream);
  }

  StreamSubscription<Journey?>? _journeySubscription;
  final _rxModel = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

  JourneyPositionModel get modelValue => _rxModel.value;

  Stream<JourneyPositionModel> get model => _rxModel.stream.distinct();

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      if (journey == null) return _rxModel.add(JourneyPositionModel());

      final updatedPosition = _calculateCurrentPosition(journey.metadata.signaledPosition, journey.journeyPoints);

      final previousModel = _rxModel.value;
      final lastPosition = journey.journeyPoints.firstWhereOrNull(
        (it) => it.order == previousModel.currentPosition?.order,
      );

      _rxModel.add(
        JourneyPositionModel(
          currentPosition: updatedPosition,
          lastPosition: lastPosition,
          previousServicePoint: _calculatePreviousServicePoint(updatedPosition, journey.journeyPoints),
          nextServicePoint: _calculateNextServicePoint(updatedPosition, journey.journeyPoints),
          nextStop: _calculateNextStop(updatedPosition, journey.journeyPoints),
        ),
      );
    });
  }

  JourneyPoint? _calculateCurrentPosition(SignaledPosition? signaledPosition, List<JourneyPoint> journeyPoints) {
    if (journeyPoints.isEmpty) return null;
    if (signaledPosition == null) return journeyPoints.first;

    return journeyPoints.lastWhereOrNull((it) => it.order <= signaledPosition.order);
  }

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
}
