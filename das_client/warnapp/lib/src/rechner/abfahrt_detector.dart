import 'package:warnapp/src/rechner/ring_buffer.dart';

class AbfahrtDetector {
  AbfahrtDetector({
    required this.length,
    required this.laengeHalt,
    required this.schwelleFahrt,
    required this.schwelleQuiet,
  }) : _ringBufferHalt = RingBuffer(laengeHalt, options: [RingBufferOptions.sum, RingBufferOptions.minMax]),
       _ringBufferFahrt = RingBuffer(length - laengeHalt) {
    reset(0);
  }

  final int laengeHalt;
  final double schwelleFahrt;
  final double schwelleQuiet;
  final int length;

  final RingBuffer _ringBufferHalt;
  final RingBuffer _ringBufferFahrt;
  int _updatesCount = 0;

  void reset(double value) {
    _updatesCount = 0;
    _ringBufferHalt.reset(value);
    _ringBufferFahrt.reset(value);
  }

  double mittelwert() {
    return _ringBufferHalt.sum / laengeHalt;
  }

  double maxAbweichungZuMittelwert(double mittelwert) {
    final min = _ringBufferHalt.min;
    final max = _ringBufferHalt.max;
    return (min - mittelwert).abs() > (max - mittelwert).abs() ? (min - mittelwert).abs() : (max - mittelwert).abs();
  }

  bool update(double value, {bool disabled = false}) {
    if (!disabled) {
      _ringBufferHalt.update(_ringBufferFahrt.update(value));
      _updatesCount++;
    }
    return isAbfahrt();
  }

  bool isAbfahrt() {
    if (_updatesCount < length) {
      return false;
    }
    final mittelwert = this.mittelwert();
    final maxAbweichung = maxAbweichungZuMittelwert(mittelwert);
    return _ringBufferFahrt.lastValue - mittelwert > schwelleFahrt && maxAbweichung < schwelleQuiet;
  }
}
