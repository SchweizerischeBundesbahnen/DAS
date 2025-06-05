class LocationAbfahrtDetector {
  LocationAbfahrtDetector(this.length, this.laengeHalt, this.schwelleFahrt)
    : _ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  final int length;
  final int laengeHalt;
  final double schwelleFahrt;

  final List<double> _ringbuffer;
  int _posRingbuffer = 0;
  int _updatesCount = 0;

  void reset(double value) {
    _updatesCount = 0;
    for (int i = 0; i < length; i++) {
      _ringbuffer[i] = value;
    }
  }

  bool signalImmerVorhanden() {
    return _signalImmerVorhandenVonBis(laengeHalt, length - 1);
  }

  bool _signalImmerVorhandenVonBis(int indexVon, int indexBis) {
    int index1 = (_posRingbuffer + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _ringbuffer[index1];
      if (value == -1) {
        return false;
      }
      index1 = (index1 + 1) % length;
    }
    return true;
  }

  bool standStill() {
    return _standStillVonBis(0, laengeHalt - 1);
  }

  bool _standStillVonBis(int indexVon, int indexBis) {
    int index1 = (_posRingbuffer + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _ringbuffer[index1];
      if (value != 0) {
        return false;
      }
      index1 = (index1 + 1) % length;
    }
    return true;
  }

  bool update(double value, {bool disabled = false}) {
    if (!disabled) {
      _ringbuffer[_posRingbuffer] = value;
      _posRingbuffer = (_posRingbuffer + 1) % length;
      _updatesCount++;
    } else {
      _updatesCount = 0;
    }
    return isAbfahrt();
  }

  bool isAbfahrt() {
    if (_updatesCount < length) {
      return false;
    }
    return _getSecondLastValue() > 0 && _getLastValue() > schwelleFahrt && standStill() && signalImmerVorhanden();
  }

  double _getLastValue() {
    final indexRingbuffer = (_posRingbuffer + length - 1) % length;
    return _ringbuffer[indexRingbuffer];
  }

  double _getSecondLastValue() {
    final indexRingbuffer = (_posRingbuffer + length - 2) % length;
    return _ringbuffer[indexRingbuffer];
  }
}
