import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/hysterese.dart';

void main() {
  group('Hysterese Tests', () {
    test('Hysterese Argument', () {
      expect(
        () => Hysterese(
          state: false,
          anzahlPositiv: 3,
          schwellePositiv: 2.5,
          anzahlNegativ: 0,
          schwelleNegativ: 3.9,
        ),
        throwsArgumentError,
      );
    });

    test('Hysterese Standard Positiv', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 3,
        schwellePositiv: 2.5,
        anzahlNegativ: 0,
        schwelleNegativ: 2.25,
      );
      expect(hysterese.state, isFalse);

      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(2.4), isFalse);
      expect(hysterese.update(1.5), isFalse);

      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);

      expect(hysterese.update(2.8), isTrue);
    });

    test('Hysterese Sofort Positiv', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 0,
        schwellePositiv: 2.5,
        anzahlNegativ: 0,
        schwelleNegativ: 2.25,
      );
      expect(hysterese.state, isFalse);
      expect(hysterese.update(2.5), isTrue);
    });

    test('Hysterese Counter Positiv', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 3,
        schwellePositiv: 2.5,
        anzahlNegativ: 0,
        schwelleNegativ: 2.25,
      );
      expect(hysterese.state, isFalse);

      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(0.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
      expect(hysterese.update(1.5), isFalse);
      expect(hysterese.update(9.4), isFalse);
    });

    test('Hysterese Standard Negativ', () {
      final hysterese = Hysterese(
        state: true,
        anzahlPositiv: 0,
        schwellePositiv: 2.5,
        anzahlNegativ: 2,
        schwelleNegativ: 2.25,
      );
      expect(hysterese.state, isTrue);

      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(9.4), isTrue);

      expect(hysterese.update(0.5), isTrue);
      expect(hysterese.update(0.6), isTrue);

      expect(hysterese.update(0.7), isFalse);
    });

    test('Keine Hysterese', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 3,
        schwellePositiv: 2.5,
        anzahlNegativ: 4,
        schwelleNegativ: 2.5,
      );
      expect(hysterese.state, isFalse);

      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isFalse);
      expect(hysterese.update(2.5), isTrue);
      expect(hysterese.update(2.5), isTrue);
    });

    test('Hysterese Counter Negativ', () {
      final hysterese = Hysterese(
        state: true,
        anzahlPositiv: 0,
        schwellePositiv: 2.5,
        anzahlNegativ: 43,
        schwelleNegativ: 2.25,
      );
      expect(hysterese.state, isTrue);

      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(0.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
      expect(hysterese.update(1.5), isTrue);
      expect(hysterese.update(9.4), isTrue);
    });

    test('Hysterese Positiv Negativ', () {
      final hysterese = Hysterese(
        state: true,
        anzahlPositiv: 3,
        schwellePositiv: 0.5,
        anzahlNegativ: 5,
        schwelleNegativ: 0.5,
      );
      expect(hysterese.state, isTrue);

      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);

      expect(hysterese.update(0), isTrue);
      expect(hysterese.update(0), isTrue);
      expect(hysterese.update(0), isTrue);
      expect(hysterese.update(0), isTrue);
      expect(hysterese.update(0), isTrue);

      expect(hysterese.update(0), isFalse);

      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);
      expect(hysterese.update(0), isFalse);

      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(2), isFalse);

      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
      expect(hysterese.update(2), isTrue);
    });

    test('Hysterese Schwelle', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 3,
        schwellePositiv: 2.5,
        anzahlNegativ: 4,
        schwelleNegativ: 2.5,
      );
      expect(hysterese.state, isFalse);

      update(hysterese, 2.5, false, false, false);
      update(hysterese, 2.5, false, false, false);
      update(hysterese, 2.5, false, false, false);
      update(hysterese, 2.5, true, true, false);
      update(hysterese, 2.5, true, false, false);
      update(hysterese, 2.5, true, false, false);
      update(hysterese, 2.5, true, false, false);
      update(hysterese, 2.5, false, false, true);
      update(hysterese, 2.5, false, false, false);
      update(hysterese, 2.5, false, false, false);
      update(hysterese, 2.5, true, true, false);
      update(hysterese, 2.5, true, false, false);
    });

    test('Hysterese Absolut Nur Positive Werte', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 2,
        schwellePositiv: 12,
        anzahlNegativ: 2,
        schwelleNegativ: 6,
        absolut: true,
      );

      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(13), isFalse);
      expect(hysterese.update(13), isFalse);
      expect(hysterese.update(13), isTrue);
      expect(hysterese.update(11), isTrue);
      expect(hysterese.update(11), isTrue);
      expect(hysterese.update(11), isTrue);
      expect(hysterese.update(5), isTrue);
      expect(hysterese.update(5), isTrue);
      expect(hysterese.update(5), isFalse);
    });

    test('Hysterese Absolut Nur Negative Werte', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 2,
        schwellePositiv: 12,
        anzahlNegativ: 2,
        schwelleNegativ: 6,
        absolut: true,
      );

      expect(hysterese.update(-2), isFalse);
      expect(hysterese.update(-2), isFalse);
      expect(hysterese.update(-2), isFalse);
      expect(hysterese.update(-13), isFalse);
      expect(hysterese.update(-13), isFalse);
      expect(hysterese.update(-13), isTrue);
      expect(hysterese.update(-11), isTrue);
      expect(hysterese.update(-11), isTrue);
      expect(hysterese.update(-11), isTrue);
      expect(hysterese.update(-5), isTrue);
      expect(hysterese.update(-5), isTrue);
      expect(hysterese.update(-5), isFalse);
    });

    test('Hysterese Absolut Gemischte Vorzeichen', () {
      final hysterese = Hysterese(
        state: false,
        anzahlPositiv: 2,
        schwellePositiv: 12,
        anzahlNegativ: 2,
        schwelleNegativ: 6,
        absolut: true,
      );

      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(-2), isFalse);
      expect(hysterese.update(2), isFalse);
      expect(hysterese.update(-13), isFalse);
      expect(hysterese.update(13), isFalse);
      expect(hysterese.update(-13), isTrue);
      expect(hysterese.update(11), isTrue);
      expect(hysterese.update(-11), isTrue);
      expect(hysterese.update(11), isTrue);
      expect(hysterese.update(-5), isTrue);
      expect(hysterese.update(5), isTrue);
      expect(hysterese.update(-5), isFalse);
    });
  });
}

void update(
  Hysterese hysterese,
  double value,
  bool expectedState,
  bool expectedPositiveSchwelleErkannt,
  bool expectedNegativeSchwelleErkannt,
) {
  expect(hysterese.update(value), equals(expectedState));
  expect(hysterese.state, equals(expectedState));
  expect(hysterese.positiveSchwelleErkannt, equals(expectedPositiveSchwelleErkannt));
  expect(hysterese.negativeSchwelleErkannt, equals(expectedNegativeSchwelleErkannt));
}
