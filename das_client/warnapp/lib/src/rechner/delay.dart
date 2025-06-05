class Delay {
  Delay(this.length) : assert(length > 0), x = List.filled(length, 0.0);

  final int length;
  List<double> x;

  double _value = 0.0;
  int _index = 0;

  double updateWithNewSample(double newSample) {
    _value = x[_index];
    x[_index] = newSample;
    _index = (_index + 1) % length; // fastRingBufferIncrement logic
    return _value;
  }

  double resetWithNewSample(double newSample) {
    x = List.filled(length, newSample);
    return updateWithNewSample(newSample);
  }
}
