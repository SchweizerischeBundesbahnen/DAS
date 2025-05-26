import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/delta.dart';
import 'package:warnapp/src/rechner/vector.dart';

void main() {
  group('WAPDelta Tests', () {
    test('0 Based Delta With Vectors', () {
      final delta = Delta();

      final v1 = Vector(1, 0, 0);
      final v2 = Vector(-1, 0, 0);

      final result = delta.updateWithDistanceBetween(v1, v2);
      expect(result, closeTo(2, 0.00001));
    });

    test('1 Based Delta With Vectors', () {
      final delta = Delta();
      delta.lastDistance = 1;

      final v1 = Vector(1, 0, 0);
      final v2 = Vector(-1, 0, 0);

      final result = delta.updateWithDistanceBetween(v1, v2);
      expect(result, closeTo(1, 0.00001));
    });

    test('0 Based Delta', () {
      final delta = Delta();

      final result = delta.updateWithDistance(2);
      expect(result, closeTo(2, 0.00001));
    });

    test('1 Based Delta', () {
      final delta = Delta();
      delta.lastDistance = 1;

      final result = delta.updateWithDistance(2);
      expect(result, closeTo(1, 0.00001));
    });
  });
}
