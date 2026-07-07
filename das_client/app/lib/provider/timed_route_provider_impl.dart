import 'package:app/provider/timed_route_provider.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class TimedRouteProviderImpl implements TimedRouteProvider {
  /// See https://github.com/SchweizerischeBundesbahnen/DAS/issues/1419 for the definition of timed advancement routes
  static const _timedRoutes = [
    // Iselle -> Varzo -> Preglia -> Domodossola (bif) -> Domodossola (I)
    ['CH01952', 'CH01951', 'CH01950', 'CH01611', 'IT01003'],

    // Pino Confine -> PINT -> Maccagno -> Colmegna -> Luino (I)
    ['CH15419', 'CH05862', 'CH05861', 'CH05874', 'IT01113'],
  ];

  @override
  bool isInTimedAdvancementRoute(JourneyPoint? updatedPosition, List<JourneyPoint> journeyPoints) {
    if (updatedPosition == null) return false;
    if (updatedPosition is! ServicePoint) return false;

    final timedRoute = _timedRoutes.firstWhereOrNull((it) => it.contains(updatedPosition.locationCode));
    if (timedRoute == null) return false;

    final nextServicePoint = _calculateNextServicePoint(journeyPoints, updatedPosition, timedRoute);

    return nextServicePoint != null;
  }

  ServicePoint? _calculateNextServicePoint(
    List<JourneyPoint> journeyPoints,
    ServicePoint updatedPosition,
    List<String> timedRoute,
  ) {
    final servicePoints = journeyPoints.whereType<ServicePoint>().toList();
    final updatedPositionIndex = servicePoints.indexOf(updatedPosition);

    final nextServicePoint = servicePoints
        .skip(updatedPositionIndex + 1)
        .firstWhereOrNull(
          (sP) => timedRoute.contains(sP.locationCode) && sP.arrivalDepartureTime?.plannedArrivalTime != null,
        );
    return nextServicePoint;
  }

  @override
  (Duration, ServicePoint)? calculateNextTimedServicePoint(
    JourneyPoint updatedPosition,
    List<JourneyPoint> journeyPoints,
  ) {
    if (updatedPosition is! ServicePoint) return null;

    final timedRoute = _timedRoutes.firstWhereOrNull((it) => it.contains(updatedPosition.locationCode));
    if (timedRoute == null) return null;

    final nextServicePoint = _calculateNextServicePoint(journeyPoints, updatedPosition, timedRoute);
    if (nextServicePoint == null) return null;

    final currentTime = clock.now();
    final plannedArrivalTime = nextServicePoint.arrivalDepartureTime!.plannedArrivalTime;

    return (plannedArrivalTime!.difference(currentTime), nextServicePoint);
  }
}
