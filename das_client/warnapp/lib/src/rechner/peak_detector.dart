class PeakDetector {
  PeakDetector(this.length, this.borderLength, this._differenzMittelwert, this._schwelle, this._schwelleBorder)
    : assert(length > 0 && borderLength > 0, 'length and borderLength must be greater than zero'),
      assert(borderLength * 2 < length, 'length must be larger then two times borderLength'),
      x = List<double>.filled(length, 0.0) {
    initWithValue(0.0);
  }

  final int length;
  final int borderLength;
  final double _differenzMittelwert;
  final double _schwelle;
  final double _schwelleBorder;
  final List<double> x;
  int index = 0;

  void initWithValue(double value) {
    for (int i = 0; i < length; i++) {
      x[i] = value;
    }
  }

  double _mittelwertGesamterBuffer() {
    double summe = 0.0;
    for (final value in x) {
      summe += value;
    }
    return summe / length;
  }

  double mittelwert1() {
    return _mittelwertVon(0, borderLength - 1);
  }

  double mittelwert2() {
    return _mittelwertVon(length - borderLength, length - 1);
  }

  double _mittelwertVon(int indexVon, int indexBis) {
    double summe = 0.0;
    int index1 = (index + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      summe += value;
      index1 = (index1 + 1) % length;
    }
    return summe / ((indexBis - indexVon) + 1);
  }

  double maxAbweichungZuMittelwert(double mittelwert) {
    return _maxAbweichungVon(borderLength, length - borderLength - 1, mittelwert);
  }

  double max1ZuMittelwert(double mittelwert) {
    return _maxAbweichungVon(0, borderLength - 1, mittelwert);
  }

  double max2ZuMittelwert(double mittelwert) {
    return _maxAbweichungVon(length - borderLength, length - 1, mittelwert);
  }

  double _maxAbweichungVon(int indexVon, int indexBis, double mittelwert) {
    double maxAbweichung = 0.0;
    int index1 = (index + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      final abweichung = (value - mittelwert).abs();
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
    final mittelwert1 = this.mittelwert1();
    final mittelwert2 = this.mittelwert2();

    if ((mittelwert1 - mittelwert2).abs() > _differenzMittelwert.abs()) {
      return false;
    }

    final maxAbweichung1 = max1ZuMittelwert(mittelwert1);
    if (maxAbweichung1 > _schwelleBorder) {
      return false;
    }

    final maxAbweichung2 = max2ZuMittelwert(mittelwert2);
    if (maxAbweichung2 > _schwelleBorder) {
      return false;
    }

    final mittelwert = _mittelwertGesamterBuffer();
    final maxAbweichung = maxAbweichungZuMittelwert(mittelwert);

    return maxAbweichung > _schwelle;
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
    final stateX = peakDetectorX.update(x);
    final stateY = peakDetectorY.update(y);
    final stateZ = peakDetectorZ.update(z);
    state = stateX || stateY || stateZ;
    return state;
  }

  bool resetWithXYZ(double x, double y, double z) {
    final stateX = peakDetectorX.reset(x);
    final stateY = peakDetectorY.reset(y);
    final stateZ = peakDetectorZ.reset(z);
    state = stateX || stateY || stateZ;
    return state;
  }
}
