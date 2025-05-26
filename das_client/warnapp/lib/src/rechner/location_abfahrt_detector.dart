class LocationAbfahrtDetector {
  final int laengeHalt;
  final double schwelleFahrt;

  final int length;
  List<double> ringbuffer;
  int posRingbuffer = 0;
  int updatesCount = 0;

  LocationAbfahrtDetector(this.length, this.laengeHalt, this.schwelleFahrt)
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
    return signalImmerVorhandenVonBis(laengeHalt, length - 1);
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
    return standStillVonBis(0, laengeHalt - 1);
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

  bool update(double value, {bool disabled = false}) {
    if (!disabled) {
      ringbuffer[posRingbuffer] = value;
      posRingbuffer = (posRingbuffer + 1) % length;
      updatesCount++;
    } else {
      updatesCount = 0;
    }
    return isAbfahrt();
  }

  bool isAbfahrt() {
    if (updatesCount < length) {
      return false;
    }
    return getSecondLastValue() > 0 && getLastValue() > schwelleFahrt && standStill() && signalImmerVorhanden();
  }

  double getLastValue() {
    final indexRingbuffer = (posRingbuffer + length - 1) % length;
    return ringbuffer[indexRingbuffer];
  }

  double getSecondLastValue() {
    final indexRingbuffer = (posRingbuffer + length - 2) % length;
    return ringbuffer[indexRingbuffer];
  }
}
