import 'package:warnapp/src/rechner/vector.dart';

class Delta {
  double lastDistance = 0.0;

  double updateWithDistance(double distance) {
    final delta = distance - lastDistance;
    lastDistance = distance;
    return delta;
  }

  double updateWithDistanceBetween(Vector vector1, Vector vector2) {
    final distance = vector1.distanceTo(vector2);
    return updateWithDistance(distance);
  }
}
