class PeakDetector {
  final int length;
  final int borderLength;
  final double differenzMittelwert;
  final double schwelle;
  final double schwelleBorder;
  List<double> x;
  int index = 0;

  PeakDetector(this.length, this.borderLength, this.differenzMittelwert, this.schwelle, this.schwelleBorder)
      : assert(length > 0 && borderLength > 0, 'length and borderLength must be greater than zero'),
        assert(borderLength * 2 < length, 'length must be larger then two times borderLength'),
        x = List<double>.filled(length, 0.0) {
    initWithValue(0.0);
  }

  void initWithValue(double value) {
    for (int i = 0; i < length; i++) {
      x[i] = value;
    }
  }

  double mittelwertGesamterBuffer() {
    double summe = 0.0;
    for (double value in x) {
      summe += value;
    }
    return summe / length;
  }

  double mittelwert1() {
    return mittelwertVon(0, borderLength - 1);
  }

  double mittelwert2() {
    return mittelwertVon(length - borderLength, length - 1);
  }

  double mittelwertVon(int indexVon, int indexBis) {
    double summe = 0.0;
    int index1 = (index + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      double value = x[index1];
      summe += value;
      index1 = (index1 + 1) % length;
    }
    return summe / ((indexBis - indexVon) + 1);
  }

  double maxAbweichungZuMittelwert(double mittelwert) {
    return maxAbweichungVon(borderLength, length - borderLength - 1, mittelwert);
  }

  double max1ZuMittelwert(double mittelwert) {
    return maxAbweichungVon(0, borderLength - 1, mittelwert);
  }

  double max2ZuMittelwert(double mittelwert) {
    return maxAbweichungVon(length - borderLength, length - 1, mittelwert);
  }

  double maxAbweichungVon(int indexVon, int indexBis, double mittelwert) {
    double maxAbweichung = 0.0;
    int index1 = (index + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      double value = x[index1];
      double abweichung = (value - mittelwert).abs();
      if (abweichung > maxAbweichung) {
        maxAbweichung = abweichung;
      }
      index1 = (index1 + 1) % length;
    }
    return maxAbweichung;
  }

  bool update(double newSample) {
    x[index] = newSample;
    index = (index + 1) % length;
    double mittelwert1 = this.mittelwert1();
    double mittelwert2 = this.mittelwert2();

    if ((mittelwert1 - mittelwert2).abs() > differenzMittelwert.abs()) {
      return false;
    }

    double maxAbweichung1 = max1ZuMittelwert(mittelwert1);
    if (maxAbweichung1 > schwelleBorder) {
      return false;
    }

    double maxAbweichung2 = max2ZuMittelwert(mittelwert2);
    if (maxAbweichung2 > schwelleBorder) {
      return false;
    }

    double mittelwert = mittelwertGesamterBuffer();
    double maxAbweichung = maxAbweichungZuMittelwert(mittelwert);

    return maxAbweichung > schwelle;
  }

  bool reset(double newSample) {
    initWithValue(newSample);
    return update(newSample);
  }
}

class PeakDetector3D {
  final PeakDetector peakDetectorX;
  final PeakDetector peakDetectorY;
  final PeakDetector peakDetectorZ;
  bool state = false;

  PeakDetector3D(int length, int borderLength, double differenzMittelwert, double schwelle, double schwelleBorder)
      : peakDetectorX = PeakDetector(length, borderLength, differenzMittelwert, schwelle, schwelleBorder),
        peakDetectorY = PeakDetector(length, borderLength, differenzMittelwert, schwelle, schwelleBorder),
        peakDetectorZ = PeakDetector(length, borderLength, differenzMittelwert, schwelle, schwelleBorder);

  bool updateXYZ(double x, double y, double z) {
    bool stateX = peakDetectorX.update(x);
    bool stateY = peakDetectorY.update(y);
    bool stateZ = peakDetectorZ.update(z);
    state = stateX || stateY || stateZ;
    return state;
  }

  bool resetWithXYZ(double x, double y, double z) {
    bool stateX = peakDetectorX.reset(x);
    bool stateY = peakDetectorY.reset(y);
    bool stateZ = peakDetectorZ.reset(z);
    state = stateX || stateY || stateZ;
    return state;
  }
}
