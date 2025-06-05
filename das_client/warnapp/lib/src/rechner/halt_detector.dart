import 'dart:math';

class HaltDetector {
  HaltDetector(this.length, this.laengeHalt, this.schwelleHalt, this.schwelleQuiet)
    : _ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  final int length;
  final int laengeHalt;
  final double schwelleHalt;
  final double schwelleQuiet;

  final List<double> _ringbuffer;
  int _posRingbuffer = 0;

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      _ringbuffer[i] = value;
    }
  }

  bool update(double value) {
    _ringbuffer[_posRingbuffer] = value;
    _posRingbuffer = _posRingbuffer + 1 >= length ? 0 : _posRingbuffer + 1;

    return isHalt();
  }

  bool isHalt() {
    return _getMin(0, laengeHalt) < schwelleHalt && _getMaxAbs(laengeHalt, length - laengeHalt) < schwelleQuiet;
  }

  double _getMin(int beginIndex, int calcLength) {
    double result = double.maxFinite;
    int indexRingbuffer = (_posRingbuffer + beginIndex) % length; // fastRingBufferSet logic

    for (int i = 0; i < calcLength; i++) {
      final value = _ringbuffer[indexRingbuffer];
      result = min(result, value);
      indexRingbuffer = indexRingbuffer + 1 >= length ? 0 : indexRingbuffer + 1;
    }
    return result;
  }

  double _getMaxAbs(int beginIndex, int calcLength) {
    double result = 0.0;
    int indexRingbuffer = (_posRingbuffer + beginIndex) % length; // fastRingBufferSet logic

    for (int i = 0; i < calcLength; i++) {
      final value = _ringbuffer[indexRingbuffer];
      result = max(result, value.abs());
      indexRingbuffer = indexRingbuffer + 1 >= length ? 0 : indexRingbuffer + 1;
    }
    return result;
  }
}
