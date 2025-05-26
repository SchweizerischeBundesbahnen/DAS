class LocationHaltDetector {
  final double schwelleMin;
  final double schwelleMax;

  final int length;
  List<double> ringbuffer;
  int posRingbuffer = 0;
  int updatesCount = 0;

  LocationHaltDetector(this.length, this.schwelleMin, this.schwelleMax)
      : ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  void reset(double value) {
    updatesCount = 0;
    for (int i = 0; i < length; i++) {
      ringbuffer[i] = value;
    }
  }

  bool signalImmerVorhanden() {
    return signalImmerVorhandenVonBis(0, length - 1);
  }

  bool signalImmerVorhandenVonBis(int indexVon, int indexBis) {
    int index1 = (posRingbuffer + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = ringbuffer[index1];
      if (value == -1) {
        return false;
      }
      index1 = (index1 + 1) % length;
    }
    return true;
  }

  bool standStill() {
    return standStillVonBis(1, length - 1);
  }

  bool standStillVonBis(int indexVon, int indexBis) {
    int index1 = (posRingbuffer + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = ringbuffer[index1];
      if (value != 0) {
        return false;
      }
      index1 = (index1 + 1) % length;
    }
    return true;
  }

  bool update(double value) {
    ringbuffer[posRingbuffer] = value;
    posRingbuffer = (posRingbuffer + 1) % length;
    updatesCount++;

    return isHalt();
  }

  bool isHalt() {
    if (updatesCount < length) {
      return false;
    }
    final firstValue = getFirstValue();
    return firstValue >= schwelleMin && firstValue < schwelleMax && standStill() && signalImmerVorhanden();
  }

  double getFirstValue() {
    final indexRingbuffer = posRingbuffer % length;
    return ringbuffer[indexRingbuffer];
  }
}
