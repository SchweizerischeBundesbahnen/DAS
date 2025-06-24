import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/abfahrt_detector.dart';

const double accuracy = 0.00001;

void main() {
  group('AbfahrtDetector Tests', () {
    test('is Abfahrt ok', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 1.0,
        schwelleQuiet: 0.001,
      );
      fillBuffer(detector, [0, 0, 0, 0, 0, 0, 0, 0, 5]);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('when disabled kein update', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 1.0,
        schwelleQuiet: 0.001,
      );
      fillBuffer(detector, [0, 0, 0, 0, 0, 0, 0, 0, 5]);
      expect(detector.isAbfahrt(), isTrue);
      detector.update(0, disabled: true);
      expect(detector.isAbfahrt(), isTrue);
      detector.update(0, disabled: false);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('is Abfahrt ansteigend', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 8.5,
        schwelleQuiet: 2.5,
      );
      fillBuffer(detector, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('mittelwert', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 8.5,
        schwelleQuiet: 2.5,
      );
      fillBuffer(detector, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(detector.mittelwert(), closeTo(3.5, accuracy));
    });

    test('mittelwert mit negativen Werten', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 8.5,
        schwelleQuiet: 2.5,
      );
      fillBuffer(detector, [1, -2, 3, -4, 5, 6, 7, 8, 9]);
      expect(detector.mittelwert(), closeTo(1.5, accuracy));
    });

    test('max Abweichung zu mittelwert', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 8.5,
        schwelleQuiet: 2.5,
      );
      fillBuffer(detector, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(detector.maxAbweichungZuMittelwert(3.5), closeTo(2.5, accuracy));
    });

    test('max Abweichung zu mittelwert mit negativen Werten', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 8.5,
        schwelleQuiet: 2.5,
      );
      fillBuffer(detector, [1, -2, 3, -4, 5, 6, 7, 8, 9]);
      expect(detector.maxAbweichungZuMittelwert(1.5), closeTo(5.5, accuracy));
    });

    test('dass mittelwert von letzten Wert abgezogen wird', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 1.0,
        schwelleQuiet: 0.51,
      );

      fillBuffer(detector, [10, 11, 10, 11, 10, 11, 2, 2, 2]);
      expect(detector.isAbfahrt(), isFalse);

      fillBuffer(detector, [10, 11, 10, 11, 10, 11, 2, 2, 12]);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('während Initialisierung keine Abfahrt', () {
      final detector = AbfahrtDetector(
        length: 9,
        laengeHalt: 6,
        schwelleFahrt: 1.0,
        schwelleQuiet: 0.001,
      );

      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(2.2), isFalse);
      expect(detector.update(2.2), isFalse);
      expect(detector.update(2.2), isTrue);
    });
  });
}

void fillBuffer(AbfahrtDetector detector, List<double> values) {
  detector.reset(99999999);

  for (final value in values) {
    detector.update(value);
  }
}
