class FahrtHysterese {
  FahrtHysterese(this.length, this.schwelleFahrt, this.sollAnzahlUeberSchwelle)
    : assert(length > 0),
      ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  int length;
  double schwelleFahrt;
  int sollAnzahlUeberSchwelle;
  List<double> ringbuffer;
  int posRingbuffer = 0;
  bool fahrt = false;

  int _anzahlUeberSchwelle = 0;

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      ringbuffer[i] = value;
    }
    if (value >= schwelleFahrt) {
      fahrt = true;
      _anzahlUeberSchwelle = length;
    } else {
      fahrt = false;
      _anzahlUeberSchwelle = 0;
    }
  }

  bool update(double value) {
    final lastValue = ringbuffer[posRingbuffer];
    ringbuffer[posRingbuffer] = value;
    posRingbuffer = posRingbuffer + 1 >= length ? 0 : posRingbuffer + 1;

    if (lastValue >= schwelleFahrt) {
      _anzahlUeberSchwelle--;
    }

    if (value >= schwelleFahrt) {
      _anzahlUeberSchwelle++;
    }

    fahrt = _anzahlUeberSchwelle >= sollAnzahlUeberSchwelle;
    return fahrt;
  }
}
