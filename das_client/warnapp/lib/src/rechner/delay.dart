class Delay {
  Delay(this.length) : assert(length > 0), x = List.filled(length, 0.0);

  final int length;
  double value = 0.0;
  List<double> x;
  int index = 0;

  double updateWithNewSample(double newSample) {
    value = x[index];
    x[index] = newSample;
    index = (index + 1) % length; // fastRingBufferIncrement logic
    return value;
  }

  double resetWithNewSample(double newSample) {
    x = List.filled(length, newSample);
    return updateWithNewSample(newSample);
  }
}
