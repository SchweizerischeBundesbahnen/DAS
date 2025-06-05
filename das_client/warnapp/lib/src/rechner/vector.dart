import 'dart:math';

class Vector {
  const Vector(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

extension VectorExtension on Vector {
  double distanceTo(Vector otherVector) {
    var s = pow(x - otherVector.x, 2).toDouble();
    s += pow(y - otherVector.y, 2).toDouble();
    s += pow(z - otherVector.z, 2).toDouble();
    return sqrt(s);
  }
}
