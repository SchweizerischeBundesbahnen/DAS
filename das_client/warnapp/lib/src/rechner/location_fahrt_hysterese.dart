import 'package:warnapp/src/rechner/ring_buffer.dart';

class LocationFahrtHysterese {
  LocationFahrtHysterese(this.schwelleSpeed, this.gueltigkeitsDauer)
    : _ringBuffer = RingBuffer(gueltigkeitsDauer, options: [RingBufferOptions.minMax]);

  final double schwelleSpeed;
  final int gueltigkeitsDauer;
  int count = 0;

  final RingBuffer _ringBuffer;
  double _speed = -1.0;

  bool updateWithSpeed(double speed, double timestamp) {
    count++;
    if (timestamp > 0) {
      _speed = speed;
      count = 0;
    }
    if (count >= gueltigkeitsDauer) {
      _speed = -1.0;
    }
    // Performanceoptimierung: Reset nicht immer bei aufrufen, sondern nur bei Fahrt
    if (_speed < 0 && isFahrt()) {
      _ringBuffer.reset(0.0);
    }
    _ringBuffer.update(_speed);
    return isFahrt();
  }

  bool isFahrt() {
    return _ringBuffer.max >= schwelleSpeed;
  }
}
