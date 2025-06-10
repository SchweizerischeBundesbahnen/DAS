import 'package:warnapp/src/rechner/ring_buffer.dart';

class Integrator {
  Integrator(this.length) : assert(length > 0, 'length must be greater than zero') {
    _ringBuffer = RingBuffer(length, options: [RingBufferOptions.sum]);
    _initWithValue(0.0);
  }

  final int length;

  double _value = 0.0;
  late RingBuffer _ringBuffer;

  void _initWithValue(double value) {
    _ringBuffer.reset(value);
    _value = _ringBuffer.sum;
  }

  double updateWithNewSample(double newSample, {bool disabled = false}) {
    if (disabled) {
      return _value;
    } else {
      return update(newSample);
    }
  }

  double update(double newSample) {
    _ringBuffer.update(newSample);
    _value = _ringBuffer.sum;
    return _value;
  }
}
