import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/floating_average.dart';

void main() {
  group('FloatingAverage Tests', () {
    test('Update Gleitender Durchschnitt Empty', () {
      final d = FloatingAverage(10, 1.0);
      expect(d.average, equals(0.0));
    });

    test('Update Gleitender Durchschnitt Update 1', () {
      final d = FloatingAverage(1000, 1.0);
      d.update(3.0);
      expect(d.average, equals(0.003));
    });

    test('Update Gleitender Durchschnitt Update 2', () {
      final d = FloatingAverage(10, 1.0);
      d.update(0.3);
      expect(d.average, equals(0.03));
    });
  });
}
