enum RingBufferOptions {
  none,
  sum,
  minMax,
}

class RingBuffer {
  RingBuffer(this.length, {this.options = const [RingBufferOptions.none]})
    : assert(length > 0),
      _x = List<double>.filled(length, 0.0);

  final int length;
  final List<RingBufferOptions> options;
  double firstValue = 0;
  double lastValue = 0;
  double lastRemovedValue = 0;
  double sum = 0;
  double min = 0;
  double max = 0;

  final List<double> _x;
  int _index = 0;

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      _x[i] = value;
    }
    sum = value * length;
    min = value;
    max = value;
    firstValue = value;
    lastValue = value;
    lastRemovedValue = 0;
  }

  double update(double newValue) {
    lastRemovedValue = firstValue;

    _x[_index] = newValue;
    _index = _index + 1 >= length ? 0 : _index + 1;

    lastValue = newValue;
    if (options.contains(RingBufferOptions.sum)) {
      sum = sum + newValue - lastRemovedValue;
    }
    final indexRingbuffer = _index; // fastRingBufferSet logic
    firstValue = _x[indexRingbuffer];

    if (options.contains(RingBufferOptions.minMax)) {
      if (newValue > max) {
        max = newValue;
      } else if (lastRemovedValue >= max) {
        max = _maxValue();
      }

      if (newValue < min) {
        min = newValue;
      } else if (lastRemovedValue <= min) {
        min = _minValue();
      }
    }
    return lastRemovedValue;
  }

  double _maxValue() {
    double max = lastValue;

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (_index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _x[index1];
      if (value > max) {
        max = value;
      }
      index1 = index1 + 1 >= length ? 0 : index1 + 1;
    }
    return max;
  }

  double _minValue() {
    double min = lastValue;

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (_index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _x[index1];
      if (value < min) {
        min = value;
      }
      index1 = index1 + 1 >= length ? 0 : index1 + 1;
    }
    return min;
  }

  List<double> values() {
    final values = List<double>.filled(length, 0.0);

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (_index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _x[index1];
      values[i] = value;
      index1 = index1 + 1 >= length ? 0 : index1 + 1;
    }
    return values;
  }

  String stringWithFormat(int fractionLength, String delimiter) {
    final result = StringBuffer();

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (_index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = _x[index1];
      if (i > 0) {
        result.write(delimiter);
      }
      result.write(value.toStringAsFixed(fractionLength)); // Formatierung analog zu Objective-C
      index1 = index1 + 1 >= length ? 0 : index1 + 1;
    }
    return result.toString();
  }
}
