class FloatingAverage {
  final int length;
  final double maxDelta;
  double average = 0.0;

  FloatingAverage(this.length, this.maxDelta) {
    resetWithAverageValue(0.0);
  }

  /// Setzt den Durchschnittswert auf den gegebenen Wert.
  void resetWithAverageValue(double value) {
    average = value;
  }

  /// Berechnet den gleitenden Durchschnittswert mit dem gegebenen Wert.
  /// Weicht der gegebene Wert mehr als das gegebene Delta von dem
  /// Durchschnitt ab, wird true zurückgegeben.
  bool update(double inValue) {
    average = ((average * (length - 1)) + inValue) / length;
    return (average - inValue).abs() > maxDelta;
  }
}
