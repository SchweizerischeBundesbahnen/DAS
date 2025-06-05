import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/signal_keeper_3d.dart';
import 'package:warnapp/src/rechner/vector.dart';

void main() {
  group('SignalKeeper3D Tests', () {
    test('XYZ', () {
      final keeper3d = SignalKeeper3D();

      final vector = Vector(1, 2, 3);
      keeper3d.updateWithValue(vector, 1.0);

      expect(keeper3d.x, equals(1));
      expect(keeper3d.y, equals(2));
      expect(keeper3d.z, equals(3));
    });

    test('Factor', () {
      final keeper3d = SignalKeeper3D();

      final vector = Vector(1, 2, 3);
      keeper3d.updateWithValue(vector, 0.1);

      expect(keeper3d.x, closeTo(0.1, 0.000001));
      expect(keeper3d.y, closeTo(0.2, 0.000001));
      expect(keeper3d.z, closeTo(0.3, 0.000001));
    });
  });
}
