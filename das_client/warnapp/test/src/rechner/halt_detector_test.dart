import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/halt_detector.dart';

void main() {
  group('HaltDetector Tests', () {
    test('Hat Gebremst Simple', () {
      final detector = HaltDetector(3, 1, -2.0, 0.001);
      fillBuffer(detector, [-3, 0, 0]);
      expect(detector.isHalt(), isTrue);
    });

    test('Hat Gebremst Von Positiv Nach Negativ', () {
      final detector = HaltDetector(9, 6, -2.0, 0.001);
      fillBuffer(detector, [2, -1, -2, -3, -2, -1, 0, 0, 0]);
      expect(detector.isHalt(), isTrue);
    });

    test('Nicht Gebremst', () {
      final detector = HaltDetector(9, 6, -2.0, 0.001);
      fillBuffer(detector, [2, 0, -1, 0, 0, 0, 0, 0, 0]);
      expect(detector.isHalt(), isFalse);
    });
  });
}

void fillBuffer(HaltDetector detector, List<double> values) {
  detector.reset(99999999.0);
  for (final value in values) {
    detector.update(value);
  }
}
