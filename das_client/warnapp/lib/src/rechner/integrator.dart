import 'package:warnapp/src/rechner/ring_buffer.dart';

class Integrator {
  Integrator(this.length) : assert(length > 0, 'length must be greater than zero') {
    ringBuffer = RingBuffer(length, options: [RingBufferOptions.sum]);
    initWithValue(0.0);
  }

  double value = 0.0;
  final int length;
  late RingBuffer ringBuffer;

  void initWithValue(double value) {
    ringBuffer.reset(value);
    this.value = ringBuffer.sum;
  }

  double updateWithNewSample(double newSample, {bool disabled = false}) {
    if (disabled) {
      return value;
    } else {
      return update(newSample);
    }
  }

  double update(double newSample) {
    ringBuffer.update(newSample);
    value = ringBuffer.sum;
    return value;
  }
}
