import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/location_abfahrt_detector.dart';

void main() {
  group('LocationAbfahrtDetector Tests', () {
    test('isAbfahrt should return true when Aktueler Wert Ueber Schwelle Und Letzter Wert Groesser Null', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.9, 5.0]);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('isAbfahrt should return false when Aktueler Wert Ueber Schwelle Und Letzter Wert Gleich 0', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0]);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('isAbfahrt should return true when Aktueler Wert Ueber Schwelle Und Letzter Wert Gleich Aktueller Wert', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0]);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('isAbfahrt should return false when Aktueler Wert Unter Schwelle', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9]);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('isAbfahrt should return false when Ansteigend', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('standStill should return true when Alle Null Sind', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 8.0, 9.0]);
      expect(detector.standStill(), isTrue);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('standStill should return false when Letzter Wert Im Halt Negativ Ist', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 7.0, 8.0, 9.0]);
      expect(detector.standStill(), isFalse);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('standStill should return true nach Weiteren Updates', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [3.0, 4.0, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 8.0, 9.0]);
      expect(detector.standStill(), isTrue);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('standStill should return false nach Erster Wert Im Halt Nicht Null Ist', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [3.0, 4.0, 4.0, 5.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 8.0, 9.0]);
      expect(detector.standStill(), isFalse);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('signalImmerVorhanden should return true when Alle Signale Null Oder Groesser', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 9.0]);
      expect(detector.signalImmerVorhanden(), isTrue);
      expect(detector.isAbfahrt(), isTrue);
    });

    test('signalImmerVorhanden should return false when Erstes Signal Negativ', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 9.0]);
      expect(detector.signalImmerVorhanden(), isFalse);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('signalImmerVorhanden should return false when Letztes Signal Negativ', () {
      final detector = LocationAbfahrtDetector(9, 6, 8.5);
      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0.0, -1.0]);
      expect(detector.signalImmerVorhanden(), isFalse);
      expect(detector.isAbfahrt(), isFalse);
    });

    test('update should return false waehrend Initialisierung', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);

      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(1.1), isFalse); // <-- hier läuft noch die Initialisierung
      expect(detector.update(1.1), isFalse); // <-- hier läuft noch die Initialisierung
      expect(detector.update(1.1), isTrue); // <-- hier ist Initialisierung abgeschlossen, daher TRUE
    });

    test('update should return true when Not Disabled', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);

      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1]);

      expect(detector.update(5.0, disabled: false), isTrue);
    });

    test('update should return false when Disabled', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);

      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);

      expect(detector.update(5.0, disabled: true), isFalse);
    });

    test('update should return false after Disable', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);

      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);

      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(4.9), isFalse);
      expect(detector.update(5.0), isFalse); // <-- ohne Disabled würde hier wieder eine Abfahrt erkannt
    });

    test('update should return true after Disable Und Buffer Wieder Voll', () {
      final detector = LocationAbfahrtDetector(9, 6, 1.0);

      fillBuffer(detector, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);

      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(5.0, disabled: true), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(0.0), isFalse);
      expect(detector.update(4.9), isFalse);
      expect(detector.update(5.0), isTrue);
    });
  });
}

void fillBuffer(LocationAbfahrtDetector detector, List<double> values) {
  detector.reset(99999999.0);

  for (final value in values) {
    detector.update(value);
  }
}
