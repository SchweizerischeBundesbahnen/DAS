import 'dart:math';

import 'package:warnapp/src/rechner/vector.dart';

class VectorCalculator {
  VectorCalculator._();

  static double distanceBetween(Vector vector1, Vector vector2) {
    var s = pow(vector1.x - vector2.x, 2).toDouble();
    s += pow(vector1.y - vector2.y, 2).toDouble();
    s += pow(vector1.z - vector2.z, 2).toDouble();
    return sqrt(s);
  }

  static double length(Vector vector) {
    var s = pow(vector.x, 2).toDouble();
    s += pow(vector.y, 2).toDouble();
    s += pow(vector.z, 2).toDouble();
    return sqrt(s);
  }

  static double lengthXYZ(double x, double y, double z) {
    var s = pow(x, 2).toDouble();
    s += pow(y, 2).toDouble();
    s += pow(z, 2).toDouble();
    return sqrt(s);
  }
}
