import 'dart:math';

class HaltDetector {
  final int laengeHalt;
  final double schwelleHalt;
  final double schwelleQuiet;

  final int length;
  List<double> ringbuffer;
  int posRingbuffer = 0;

  HaltDetector(this.length, this.laengeHalt, this.schwelleHalt, this.schwelleQuiet)
      : ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      ringbuffer[i] = value;
    }
  }

  bool update(double value) {
    ringbuffer[posRingbuffer] = value;
    posRingbuffer = (posRingbuffer + 1) % length; // fastRingBufferIncrement logic

    return isHalt();
  }

  bool isHalt() {
    return getMin(0, laengeHalt) < schwelleHalt && getMaxAbs(laengeHalt, length - laengeHalt) < schwelleQuiet;
  }

  double getMin(int beginIndex, int calcLength) {
    double result = double.maxFinite;
    int indexRingbuffer = (posRingbuffer + beginIndex) % length; // fastRingBufferSet logic

    for (int i = 0; i < calcLength; i++) {
      final value = ringbuffer[indexRingbuffer];
      result = min(result, value);
      indexRingbuffer = (indexRingbuffer + 1) % length; // fastRingBufferIncrement logic
    }
    return result;
  }

  double getMaxAbs(int beginIndex, int calcLength) {
    double result = 0.0;
    int indexRingbuffer = (posRingbuffer + beginIndex) % length; // fastRingBufferSet logic

    for (int i = 0; i < calcLength; i++) {
      final value = ringbuffer[indexRingbuffer];
      result = max(result, value.abs());
      indexRingbuffer = (indexRingbuffer + 1) % length; // fastRingBufferIncrement logic
    }
    return result;
  }
}
