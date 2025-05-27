import 'package:warnapp/src/rechner/ring_buffer.dart';

class AbfahrtDetector {
  final int laengeHalt;
  final double schwelleFahrt;
  final double schwelleQuiet;

  final int length;
  final RingBuffer ringBufferHalt;
  final RingBuffer ringBufferFahrt;
  int updatesCount = 0;

  AbfahrtDetector({
    required this.length,
    required this.laengeHalt,
    required this.schwelleFahrt,
    required this.schwelleQuiet,
  })  : ringBufferHalt = RingBuffer(laengeHalt, options: [RingBufferOptions.sum, RingBufferOptions.minMax]),
        ringBufferFahrt = RingBuffer(length - laengeHalt) {
    reset(0);
  }

  void reset(double value) {
    updatesCount = 0;
    ringBufferHalt.reset(value);
    ringBufferFahrt.reset(value);
  }

  double mittelwert() {
    return ringBufferHalt.sum / laengeHalt;
  }

  double maxAbweichungZuMittelwert(double mittelwert) {
    final min = ringBufferHalt.min;
    final max = ringBufferHalt.max;
    return (min - mittelwert).abs() > (max - mittelwert).abs() ? (min - mittelwert).abs() : (max - mittelwert).abs();
  }

  bool update(double value, {bool disabled = false}) {
    if (!disabled) {
      ringBufferHalt.update(ringBufferFahrt.update(value));
      updatesCount++;
    }
    return isAbfahrt();
  }

  bool isAbfahrt() {
    if (updatesCount < length) {
      return false;
    }
    final mittelwert = this.mittelwert();
    final maxAbweichung = maxAbweichungZuMittelwert(mittelwert);
    return getLastValue() - mittelwert > schwelleFahrt && maxAbweichung < schwelleQuiet;
  }

  double getLastValue() {
    return ringBufferFahrt.lastValue;
  }
}
