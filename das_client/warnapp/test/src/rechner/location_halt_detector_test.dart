import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/location_halt_detector.dart';

void main() {
  group('LocationHaltDetector Tests', () {
    test('isHalt should return true when Innerhalb Schwelle', () {
      final detector = LocationHaltDetector(4, 0.01, 1.0);
      fillBuffer(detector, [0.5, 0.0, 0.0, 0.0]);
      expect(detector.isHalt(), isTrue);
    });

    test('isHalt should return false when Unterhalb Schwelle', () {
      final detector = LocationHaltDetector(4, 0.01, 1.0);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0]);
      expect(detector.isHalt(), isFalse);
    });

    test('isHalt should return false when Oberhalb Schwelle', () {
      final detector = LocationHaltDetector(4, 0.01, 1.0);
      fillBuffer(detector, [1.5, 0.0, 0.0, 0.0]);
      expect(detector.isHalt(), isFalse);
    });

    test('isHalt should return false when Nicht Alles 0', () {
      final detector = LocationHaltDetector(4, 0.01, 1.0);
      fillBuffer(detector, [0.5, 0.0, 0.1, 0.0]);
      expect(detector.isHalt(), isFalse);
    });
  });
}

void fillBuffer(LocationHaltDetector detector, List<double> values) {
  detector.reset(99999999.0);
  for (final value in values) {
    detector.update(value);
  }
}
