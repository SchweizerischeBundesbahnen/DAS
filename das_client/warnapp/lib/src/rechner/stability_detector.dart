import 'package:warnapp/src/rechner/floating_average.dart';

class StabilityDetector {
  final int minimumCount;
  final FloatingAverage averageX;
  final FloatingAverage averageY;
  final FloatingAverage averageZ;
  int count = 0;

  StabilityDetector(int aCount, int anAverageLength, double aMaxDelta)
      : minimumCount = aCount,
        averageX = FloatingAverage(anAverageLength, aMaxDelta),
        averageY = FloatingAverage(anAverageLength, aMaxDelta),
        averageZ = FloatingAverage(anAverageLength, aMaxDelta);

  void resetWithX(double x, double y, double z) {
    averageX.resetWithAverageValue(x);
    averageY.resetWithAverageValue(y);
    averageZ.resetWithAverageValue(z);
    count = 0;
  }

  void update(double x, double y, double z) {
    final deltaX = averageX.update(x);
    final deltaY = averageY.update(y);
    final deltaZ = averageZ.update(z);
    if (deltaX || deltaY || deltaZ) {
      count = 0;
    } else {
      count++;
    }
  }

  bool get isStable => count >= minimumCount;
}
