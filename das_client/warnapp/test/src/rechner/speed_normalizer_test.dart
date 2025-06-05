import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/speed_normalizer.dart';

const double speedUndefined = -1.0;
const double noTimestamp = 0.0;

void main() {
  group('SpeedNormalizer Tests', () {
    late SpeedNormalizer speedNormalizer;

    setUp(() {
      speedNormalizer = SpeedNormalizer(5);
    });

    test('init should return undefined', () {
      expect(speedNormalizer.speed, equals(speedUndefined));
    });

    test('update should return speed when timestamp is set', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0), equals(0));
    });

    test('update should return undefined after 5 updates without timestamp set', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
    });

    test('update should return new speed when timestamp is set within length', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(0));
      expect(speedNormalizer.updateWithSpeed(2, 2.0), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp), equals(2));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
    });

    test('update should return undefined when timestamp is not set but speed is set', () {
      expect(speedNormalizer.updateWithSpeed(5, noTimestamp), equals(speedUndefined));
    });

    test('update should return undefined when new speed is undefined', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0), equals(0));
      expect(speedNormalizer.updateWithSpeed(speedUndefined, 2.0), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
    });

    test('update should return new when new speed is set after undefined', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0), equals(0));
      expect(speedNormalizer.updateWithSpeed(speedUndefined, 2.0), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 2.0), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp), equals(speedUndefined));
    });
  });
}
