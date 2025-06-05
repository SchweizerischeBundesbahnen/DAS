class FahrtHysterese {
  FahrtHysterese(this.length, this.schwelleFahrt, this.sollAnzahlUeberSchwelle)
      : assert(length > 0),
        ringbuffer = List<double>.filled(length, 0.0) {
    reset(0.0);
  }

  double schwelleFahrt;
  int length;
  int sollAnzahlUeberSchwelle;
  int anzahlUeberSchwelle = 0;
  List<double> ringbuffer;
  int posRingbuffer = 0;
  bool fahrt = false;

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      ringbuffer[i] = value;
    }
    if (value >= schwelleFahrt) {
      fahrt = true;
      anzahlUeberSchwelle = length;
    } else {
      fahrt = false;
      anzahlUeberSchwelle = 0;
    }
  }

  bool update(double value) {
    final lastValue = ringbuffer[posRingbuffer];
    ringbuffer[posRingbuffer] = value;
    posRingbuffer = posRingbuffer + 1 >= length ? 0 : posRingbuffer + 1;

    if (lastValue >= schwelleFahrt) {
      anzahlUeberSchwelle--;
    }

    if (value >= schwelleFahrt) {
      anzahlUeberSchwelle++;
    }

    fahrt = anzahlUeberSchwelle >= sollAnzahlUeberSchwelle;
    return fahrt;
  }
}
