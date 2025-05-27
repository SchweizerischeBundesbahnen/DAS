class Variance {
  final int length;
  List<double> x;
  int index = 0;
  double value = 0.0;

  Variance(this.length)
      : assert(length > 0, 'length must be greater than zero'),
        x = List<double>.filled(length, 0.0);

  void initWithValue(double value) {
    for (int i = 0; i < length; i++) {
      x[i] = value;
    }
  }

  double variance() {
    double summe = 0.0;
    double summeQuadriert = 0.0;

    for (final value in x) {
      summe += value;
      summeQuadriert += (value * value);
    }
    summe = (summe * summe);
    final variance = summeQuadriert - (summe / length);
    value = variance / (length - 1);
    return value;
  }

  double updateWithNewSample(double newSample) {
    x[index] = newSample;
    index = (index + 1) % length;
    return variance();
  }

  double resetWithNewSample(double newSample) {
    for (int n = 0; n < length; n++) {
      x[n] = newSample;
    }
    index = (index + 1) % length;
    return variance();
  }
}

class Variance3D {
  final Variance varianceX;
  final Variance varianceY;
  final Variance varianceZ;

  Variance3D(int length)
      : varianceX = Variance(length),
        varianceY = Variance(length),
        varianceZ = Variance(length);

  void resetWithX(double x, double y, double z) {
    varianceX.resetWithNewSample(x);
    varianceY.resetWithNewSample(y);
    varianceZ.resetWithNewSample(z);
  }

  void updateX(double x, double y, double z) {
    varianceX.updateWithNewSample(x);
    varianceY.updateWithNewSample(y);
    varianceZ.updateWithNewSample(z);
  }

  double summe() {
    return varianceX.value + varianceY.value + varianceZ.value;
  }
}
