import 'package:warnapp/src/rechner/signal_keeper.dart';
import 'package:warnapp/src/rechner/vector.dart';

class SignalKeeper3D implements Vector {
  SignalKeeper3D() : _keeperX = SignalKeeper(), _keeperY = SignalKeeper(), _keeperZ = SignalKeeper();

  final SignalKeeper _keeperX;
  final SignalKeeper _keeperY;
  final SignalKeeper _keeperZ;

  void updateWithValue(Vector vector, double factor) {
    _keeperX.updateWithValue(vector.x, factor);
    _keeperY.updateWithValue(vector.y, factor);
    _keeperZ.updateWithValue(vector.z, factor);
  }

  @override
  double get x => _keeperX.value;

  @override
  double get y => _keeperY.value;

  @override
  double get z => _keeperZ.value;
}
