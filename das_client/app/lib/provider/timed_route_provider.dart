import 'package:sfera/component.dart';

abstract class TimedRouteProvider {
  const TimedRouteProvider._();

  bool isInTimedAdvancementRoute(JourneyPoint? updatedPosition, List<JourneyPoint> journeyPoints);

  // Returns a tuple containing the duration until next service point is reached
  // returns negative duration if the next service point is already reached
  (Duration, ServicePoint)? calculateNextTimedServicePoint(
    JourneyPoint updatedPosition,
    List<JourneyPoint> journeyPoints,
  );
}
