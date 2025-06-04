import 'package:warnapp/src/rechner/ring_buffer.dart';

class LocationFahrtHysterese {
  LocationFahrtHysterese(this.schwelleSpeed, this.gueltigkeitsDauer)
      : ringBuffer = RingBuffer(gueltigkeitsDauer, options: [RingBufferOptions.minMax]);

  final double schwelleSpeed;
  final int gueltigkeitsDauer;
  bool fahrt = false;

  double speed = -1.0;
  int count = 0;

  RingBuffer ringBuffer;

  bool updateWithSpeed(double speed, double timestamp) {
    count++;
    if (timestamp > 0) {
      this.speed = speed;
      count = 0;
    }
    if (count >= gueltigkeitsDauer) {
      this.speed = -1.0;
    }
    // Performanceoptimierung: Reset nicht immer bei aufrufen, sondern nur bei Fahrt
    if (this.speed < 0 && isFahrt()) {
      ringBuffer.reset(0.0);
    }
    ringBuffer.update(this.speed);
    return isFahrt();
  }

  bool isFahrt() {
    return ringBuffer.max >= schwelleSpeed;
  }
}
