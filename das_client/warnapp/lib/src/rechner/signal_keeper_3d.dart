import 'package:warnapp/src/rechner/signal_keeper.dart';
import 'package:warnapp/src/rechner/vector.dart';

class SignalKeeper3D implements Vector {
  SignalKeeper3D()
      : keeperX = SignalKeeper(),
        keeperY = SignalKeeper(),
        keeperZ = SignalKeeper();

  final SignalKeeper keeperX;
  final SignalKeeper keeperY;
  final SignalKeeper keeperZ;

  void updateWithValue(Vector vector, double factor) {
    keeperX.updateWithValue(vector.x, factor);
    keeperY.updateWithValue(vector.y, factor);
    keeperZ.updateWithValue(vector.z, factor);
  }

  @override
  double get x => keeperX.value;

  @override
  double get y => keeperY.value;

  @override
  double get z => keeperZ.value;
}
