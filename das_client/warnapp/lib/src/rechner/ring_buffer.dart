enum RingBufferOptions {
  none,
  sum,
  minMax,
}

class RingBuffer {
  RingBuffer(this.length, {this.options = const [RingBufferOptions.none]})
      : assert(length > 0),
        x = List<double>.filled(length, 0.0),
        sum = 0,
        min = 0,
        max = 0,
        firstValue = 0,
        lastValue = 0,
        lastRemovedValue = 0;

  final int length;
  final List<RingBufferOptions> options;
  double firstValue;
  double lastValue;
  double lastRemovedValue;
  double sum;
  double min;
  double max;
  List<double> x;
  int index = 0;

  void reset(double value) {
    for (int i = 0; i < length; i++) {
      x[i] = value;
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

    x[index] = newValue;
    index = (index + 1) % length; // fastRingBufferIncrement logic

    lastValue = newValue;
    if (options.contains(RingBufferOptions.sum)) {
      sum = sum + newValue - lastRemovedValue;
    }
    final indexRingbuffer = index; // fastRingBufferSet logic
    firstValue = x[indexRingbuffer];

    if (options.contains(RingBufferOptions.minMax)) {
      if (newValue > max) {
        max = newValue;
      } else if (lastRemovedValue >= max) {
        max = maxValue();
      }

      if (newValue < min) {
        min = newValue;
      } else if (lastRemovedValue <= min) {
        min = minValue();
      }
    }
    return lastRemovedValue;
  }

  double maxValue() {
    double max = lastValue;

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      if (value > max) {
        max = value;
      }
      index1 = (index1 + 1) % length; // fastRingBufferIncrement logic
    }
    return max;
  }

  double minValue() {
    double min = lastValue;

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      if (value < min) {
        min = value;
      }
      index1 = (index1 + 1) % length; // fastRingBufferIncrement logic
    }
    return min;
  }

  double mean() {
    return sum / length;
  }

  double inner() {
    double skalarprodukt = 0;

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      skalarprodukt += value * value;
      index1 = (index1 + 1) % length; // fastRingBufferIncrement logic
    }
    return skalarprodukt / length;
  }

  List<double> values() {
    final values = List<double>.filled(length, 0.0);

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      values[i] = value;
      index1 = (index1 + 1) % length; // fastRingBufferIncrement logic
    }
    return values;
  }

  String stringWithFormat(int fractionLength, String delimiter) {
    final result = StringBuffer();

    final indexVon = 0;
    final indexBis = length - 1;

    int index1 = (index + indexVon) % length; // fastRingBufferSet logic
    for (int i = indexVon; i <= indexBis; i++) {
      final value = x[index1];
      if (i > 0) {
        result.write(delimiter);
      }
      result.write(value.toStringAsFixed(fractionLength)); // Formatierung analog zu Objective-C
      index1 = (index1 + 1) % length; // fastRingBufferIncrement logic
    }
    return result.toString();
  }
}
