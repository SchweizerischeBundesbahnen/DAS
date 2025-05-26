import 'package:warnapp/src/rechner/ring_buffer.dart';

class FeatureWindows {
  final List<int> windowLengths;
  late final List<RingBuffer> ringBuffers;
  late final List<RingBuffer> reversedRingBuffers;

  FeatureWindows(this.windowLengths,
      {List<RingBufferOptions> options = const [RingBufferOptions.minMax, RingBufferOptions.sum]})
      : assert(windowLengths.isNotEmpty, 'windowLengths darf nicht leer sein') {
    ringBuffers = windowLengths.map((length) => RingBuffer(length, options: options)).toList();
    reversedRingBuffers = ringBuffers.reversed.toList();
    reset(0);
  }

  void reset(double value) {
    for (final buffer in ringBuffers) {
      buffer.reset(value);
    }
  }

  double update(double newValue) {
    double value = newValue;
    for (final buffer in reversedRingBuffers) {
      value = buffer.update(value);
    }
    return value;
  }

  double meanDiff(int fromWindow, int toWindow) {
    return ringBuffers[fromWindow].mean() - ringBuffers[toWindow].mean();
  }

  double minDiff(int fromWindow, int toWindow) {
    return ringBuffers[fromWindow].min - ringBuffers[toWindow].min;
  }

  double maxDiff(int fromWindow, int toWindow) {
    return ringBuffers[fromWindow].max - ringBuffers[toWindow].max;
  }

  double innerDiff(int fromWindow, int toWindow) {
    return ringBuffers[fromWindow].inner() - ringBuffers[toWindow].inner();
  }

  double sumDiff(int fromWindow, int toWindow) {
    return ringBuffers[fromWindow].sum - ringBuffers[toWindow].sum;
  }

  double min(int window) {
    return ringBuffers[window].min;
  }

  double max(int window) {
    return ringBuffers[window].max;
  }

  double sum(int window) {
    return ringBuffers[window].sum;
  }

  double mean(int window) {
    return ringBuffers[window].mean();
  }

  double inner(int window) {
    return ringBuffers[window].inner();
  }
}
