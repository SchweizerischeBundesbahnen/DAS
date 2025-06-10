class LocationHaltDetector {
  LocationHaltDetector(this.length, this.schwelleMin, this.schwelleMax)
    : _ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  final double schwelleMin;
  final double schwelleMax;
  final int length;

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
    return _signalImmerVorhandenVonBis(0, length - 1);
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

  bool _standStill() {
    return _standStillVonBis(1, length - 1);
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

  bool update(double value) {
    _ringbuffer[_posRingbuffer] = value;
    _posRingbuffer = (_posRingbuffer + 1) % length;
    _updatesCount++;

    return isHalt();
  }

  bool isHalt() {
    if (_updatesCount < length) {
      return false;
    }
    final firstValue = _getFirstValue();
    return firstValue >= schwelleMin && firstValue < schwelleMax && _standStill() && signalImmerVorhanden();
  }

  double _getFirstValue() {
    final indexRingbuffer = _posRingbuffer % length;
    return _ringbuffer[indexRingbuffer];
  }
}
