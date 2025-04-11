import 'dart:math';

class BarrierModel {
  double x;
  double offset;
  bool movingDown;
  bool passed;
  List<double> heights;

  BarrierModel({
    required this.x,
    required this.heights,
    this.offset = 0.0,
    this.movingDown = false,
    this.passed = false,
  });

  void update(double velocity, Random rand) {
    x -= velocity;
    if (velocity > 0.03 && rand.nextBool()) {
      double offsetChange = 0.5;
      if (movingDown) {
        offset += offsetChange;
        if (offset > 30) movingDown = false;
      } else {
        offset -= offsetChange;
        if (offset < -30) movingDown = true;
      }
    }
  }
}
