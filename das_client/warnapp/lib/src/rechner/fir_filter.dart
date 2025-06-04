import 'dart:math';

import 'package:warnapp/src/rechner/vector.dart';

class FIRFilter {
  FIRFilter(this.length, {bool resetOnFirstUpdate = false}) : assert(length > 0, 'length must be greater than zero') {
    _x = List<double>.filled(length, 0.0);
    _firCoef = List<double>.filled(length, 0.0);
    _resetOnFirstUpdate = resetOnFirstUpdate;

    var summe = 0.0;
    for (int i = 0; i < length; i++) {
      _x[i] = 0;
      _firCoef[i] = (0.54 - 0.46 * cos((2 * pi * i) / (length - 1)));
      summe += _firCoef[i];
    }
    for (int i = 0; i < length; i++) {
      _firCoef[i] /= summe;
    }
  }

  final int length;
  late List<double> _firCoef;
  late List<double> _x;
  late bool _resetOnFirstUpdate;
  int _index = 0;
  bool _firstCall = true;
  double value = 0.0;

  double getFIRCoef(int index) {
    return _firCoef[index];
  }

  double updateWithNewSample(double newSample) {
    if (_firstCall) {
      _firstCall = false;
      if (_resetOnFirstUpdate) {
        return resetWithNewSample(newSample);
      }
    }

    double y = 0; // output sample
    int n;

    // Calculate the new output
    _x[_index] = newSample;
    int index1 = _index;
    for (n = 0; n < length; n++) {
      y += _firCoef[n] * _x[index1];
      index1 = (index1 - 1) % length; // fastRingBufferDecrement logic
    }
    _index = (_index + 1) % length; // fastRingBufferIncrement logic

    value = y;
    return y;
  }

  double resetWithNewSample(double newSample) {
    int n;

    // Calculate the new output
    _x[_index] = newSample;
    int index1 = _index;
    for (n = 0; n < length; n++) {
      _x[index1] = newSample;
      index1 = (index1 - 1) % length; // fastRingBufferDecrement logic
    }
    _index = (_index + 1) % length; // fastRingBufferIncrement logic

    value = newSample;
    return newSample;
  }
}

class FIRFilter3D implements Vector {
  FIRFilter filterX;
  FIRFilter filterY;
  FIRFilter filterZ;

  FIRFilter3D(int length, {bool resetOnFirstUpdate = false})
      : assert(length > 0, 'length must be greater than zero'),
        filterX = FIRFilter(length, resetOnFirstUpdate: resetOnFirstUpdate),
        filterY = FIRFilter(length, resetOnFirstUpdate: resetOnFirstUpdate),
        filterZ = FIRFilter(length, resetOnFirstUpdate: resetOnFirstUpdate);

  void resetWithXYZ(double x, double y, double z) {
    filterX.resetWithNewSample(x);
    filterY.resetWithNewSample(y);
    filterZ.resetWithNewSample(z);
  }

  void updateXYZ(double x, double y, double z) {
    filterX.updateWithNewSample(x);
    filterY.updateWithNewSample(y);
    filterZ.updateWithNewSample(z);
  }

  @override
  double get x => filterX.value;

  @override
  double get y => filterY.value;

  @override
  double get z => filterZ.value;
}
