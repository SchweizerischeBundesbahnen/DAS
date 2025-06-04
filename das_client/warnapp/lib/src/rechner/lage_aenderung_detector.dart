class LageAenderungDetector {
  LageAenderungDetector(this.length1, this.length2, this.schwelle)
      : assert(length1 > 0 && length2 > 0, 'length1 and length2 must be greater than zero'),
        length = length1 + length2,
        x = List<double>.filled(length1 + length2, 0.0) {
    initWithValue(0.0);
  }

  final int length;
  final int length1;
  final int length2;
  final double schwelle;
  List<double> x;
  int index = 0;
  int updatesCount = 0;
  double mittelwert1 = 0.0;
  double mittelwert2 = 0.0;
  double abweichungMittelwerte = 0.0;

  void initWithValue(double value) {
    updatesCount = 0;
    for (int i = 0; i < length; i++) {
      x[i] = value;
    }
  }

  double calculateMittelwert1() {
    return calculateMittelwertVon(0, length1 - 1);
  }

  double calculateMittelwert2() {
    return calculateMittelwertVon(length1, length - 1);
  }

  double calculateMittelwertVon(int indexVon, int indexBis) {
    double summe = 0.0;

    int index1 = (index + indexVon) % length;
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      summe += value;
      index1 = (index1 + 1) % length;
    }
    return summe / ((indexBis - indexVon) + 1);
  }

  double berechneAbweichungMittelwerte() {
    mittelwert1 = calculateMittelwert1();
    mittelwert2 = calculateMittelwert2();
    abweichungMittelwerte = mittelwert1 - mittelwert2;
    return abweichungMittelwerte;
  }

  bool update(double newSample) {
    updatesCount++;
    x[index] = newSample;
    index = (index + 1) % length;

    return (berechneAbweichungMittelwerte().abs() > schwelle && updatesCount >= length);
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
