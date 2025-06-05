class LageAenderungDetector {
  LageAenderungDetector(this.length1, this.length2, this.schwelle)
    : assert(length1 > 0 && length2 > 0, 'length1 and length2 must be greater than zero'),
      _length = length1 + length2,
      x = List<double>.filled(length1 + length2, 0.0) {
    initWithValue(0.0);
  }

  final int length1;
  final int length2;
  final int _length;
  final double schwelle;
  List<double> x;
  int index = 0;
  int _updatesCount = 0;
  double _mittelwert1 = 0.0;
  double _mittelwert2 = 0.0;
  double _abweichungMittelwerte = 0.0;

  void initWithValue(double value) {
    _updatesCount = 0;
    for (int i = 0; i < _length; i++) {
      x[i] = value;
    }
  }

  double calculateMittelwert1() {
    return calculateMittelwertVon(0, length1 - 1);
  }

  double calculateMittelwert2() {
    return calculateMittelwertVon(length1, _length - 1);
  }

  double calculateMittelwertVon(int indexVon, int indexBis) {
    double summe = 0.0;

    int index1 = (index + indexVon) % _length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      summe += value;
      index1 = (index1 + 1) % _length;
    }
    return summe / ((indexBis - indexVon) + 1);
  }

  double berechneAbweichungMittelwerte() {
    _mittelwert1 = calculateMittelwert1();
    _mittelwert2 = calculateMittelwert2();
    _abweichungMittelwerte = _mittelwert1 - _mittelwert2;
    return _abweichungMittelwerte;
  }

  bool update(double newSample) {
    _updatesCount++;
    x[index] = newSample;
    index = (index + 1) % _length;

    return (berechneAbweichungMittelwerte().abs() > schwelle && _updatesCount >= _length);
  }
}

class LageAenderungDetector3D {
  LageAenderungDetector lageAenderungDetectorX;
  LageAenderungDetector lageAenderungDetectorY;
  LageAenderungDetector lageAenderungDetectorZ;
  bool state = false;

  LageAenderungDetector3D(int length1, int length2, double schwelle)
    : lageAenderungDetectorX = LageAenderungDetector(length1, length2, schwelle),
      lageAenderungDetectorY = LageAenderungDetector(length1, length2, schwelle),
      lageAenderungDetectorZ = LageAenderungDetector(length1, length2, schwelle);

  bool updateXYZ(double x, double y, double z) {
    int count = 0;
    if (lageAenderungDetectorX.update(x)) count++;
    if (lageAenderungDetectorY.update(y)) count++;
    if (lageAenderungDetectorZ.update(z)) count++;

    state = count >= 2;
    return state;
  }
}
