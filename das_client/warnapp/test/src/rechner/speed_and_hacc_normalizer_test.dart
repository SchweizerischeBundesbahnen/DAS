import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/speed_and_hacc_normalizer.dart';

const double speedUndefined = -1.0;
const double noTimestamp = 0.0;
const double hacc5 = 5.0;
const double hacc10 = 10.0;
const double hacc15 = 15.0;

const int haccMinimal2Anzahl = 3;

late SpeedAndHaccNormalizer speedNormalizer;

void main() {
  group('SpeedAndHaccNormalizer Tests', () {
    setUp(() {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        hacc5,
        hacc10,
        haccMinimal2Anzahl,
      );
    });

    test('init should return undefined', () {
      expect(speedNormalizer.speed, equals(speedUndefined));
    });

    test('update should return speed when timestamp is set', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0, hacc5), equals(0));
    });

    test('update should return undefined after 5 updates without timestamp set', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return new speed when timestamp is set within length', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(2, 2.0, hacc5), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp, hacc5), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp, hacc5), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp, hacc5), equals(2));
      expect(speedNormalizer.updateWithSpeed(2, noTimestamp, hacc5), equals(2));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return undefined when timestamp is not set but speed is set', () {
      expect(speedNormalizer.updateWithSpeed(5, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return undefined when new speed is undefined', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(speedUndefined, 2.0, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return new when new speed is set after undefined', () {
      expect(speedNormalizer.updateWithSpeed(0, 1.0, hacc5), equals(0));
      expect(speedNormalizer.updateWithSpeed(speedUndefined, 2.0, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return speed when hacc gleich haccUntereSchwelle', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(0, noTimestamp, hacc5), equals(speedUndefined));
    });

    test('update should return speed when hacc unter haccUntereSchwelle', () {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        hacc10,
        hacc15,
        haccMinimal2Anzahl,
      );

      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));
    });

    test('update should return undefined when hacc über haccUntereSchwelle', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc10), equals(speedUndefined));
    });

    test('update should return undefined when hacc über haccUntereSchwelle nach hacc gleich haccUntereSchwelle', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(speedUndefined));
    });

    test('update should return speed when hacc erhöht wird', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc15), equals(speedUndefined));
    });

    test('update should return speed when hacc gleich haccObereSchwelle nach bestimmter Zeit', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc10), equals(1));
    });

    test('update should return speed when hacc zwischen haccUntereSchwelle und haccObereSchwelle nach bestimmter Zeit',
        () {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        hacc5,
        hacc15,
        haccMinimal2Anzahl,
      );

      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc10), equals(1));
    });

    test('update should return speed when hacc gleich haccObereSchwelle nach bestimmter Zeit zwei Zyklen', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc10), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 7.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 8.0, hacc5), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 9.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 10.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 11.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 12.0, hacc10), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 13.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 14.0, hacc10), equals(1));
    });

    test('update should return undefined when hacc über minimal2 erhöht wird', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc15), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc15), equals(speedUndefined));
    });

    test('update should return undefined when hacc über minimal2 erhöht wird und auf minimal2 zurück', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc15), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 7.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 8.0, hacc10), equals(1));
    });

    test('update should return speed when hacc über minimal2 erhöht wird und auf minimal zurück', () {
      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc15), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc5), equals(1));
    });

    test(
        'update should return speed when hacc gleich haccObereSchwelle nach bestimmter Zeit aber haccUntereSchwelle grösser haccObereSchwelle',
        () {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        hacc15,
        hacc10,
        haccMinimal2Anzahl,
      );

      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc10), equals(1));
    });

    test('update should return speed when haccUntereSchwelle999', () {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        999,
        999,
        1,
      );

      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(1));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc15), equals(1));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc15), equals(1));
    });

    test('update should return speed when haccUntereSchwelle0', () {
      speedNormalizer = SpeedAndHaccNormalizer(
        5,
        0,
        0,
        1,
      );

      expect(speedNormalizer.updateWithSpeed(1, 1.0, hacc5), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 2.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 3.0, hacc10), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 4.0, hacc10), equals(speedUndefined));

      expect(speedNormalizer.updateWithSpeed(1, 5.0, hacc15), equals(speedUndefined));
      expect(speedNormalizer.updateWithSpeed(1, 6.0, hacc15), equals(speedUndefined));
    });
  });
}
