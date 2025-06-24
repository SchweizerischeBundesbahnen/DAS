import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/peak_detector.dart';

const double accuracy = 0.00001;

void main() {
  group('PeakDetector Tests', () {
    test('Init Window Length 0', () {
      expect(() => PeakDetector(0, 0, 0, 0, 0), throwsAssertionError);
    });

    test('Init Border Length 0', () {
      expect(() => PeakDetector(10, 0, 0, 0, 0), throwsAssertionError);
    });

    test('Init Border Length Zu Lang', () {
      expect(() => PeakDetector(10, 5, 0, 0, 0), throwsAssertionError);
    });

    test('Init Length 6 check array', () {
      final detector = PeakDetector(6, 2, 0, 0, 0);
      expect(detector.x, equals([0.0, 0.0, 0.0, 0.0, 0.0, 0.0]));
    });

    test('Mittelwert', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      detector.x[0] = 1.2;
      detector.x[1] = 1.3;
      detector.x[2] = 1.4;
      detector.x[3] = 1.5;
      detector.x[4] = 1.6;
      detector.x[5] = 1.7;

      expect(detector.mittelwert1(), closeTo(1.25, accuracy));
      expect(detector.mittelwert2(), closeTo(1.65, accuracy));

      detector.index = 1;

      expect(detector.mittelwert1(), closeTo(1.35, accuracy));
      expect(detector.mittelwert2(), closeTo(1.45, accuracy));
    });

    test('Max Abweichung', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      detector.x[0] = 1.2;
      detector.x[1] = 1.3;
      detector.x[2] = 1.4;
      detector.x[3] = 1.5;
      detector.x[4] = 1.2;
      detector.x[5] = 1.3;

      expect(detector.maxAbweichungZuMittelwert(1.25), closeTo(0.25, accuracy));

      detector.index = 5;

      expect(detector.maxAbweichungZuMittelwert(1.25), closeTo(0.15, accuracy));
    });

    test('Max Abweichung Border', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      detector.x[0] = 1.2;
      detector.x[1] = 1.3;
      detector.x[2] = 1.4;
      detector.x[3] = 1.5;
      detector.x[4] = 1.5;
      detector.x[5] = 1.3;

      expect(detector.max1ZuMittelwert(1.25), closeTo(0.05, accuracy));
      expect(detector.max2ZuMittelwert(1.4), closeTo(0.1, accuracy));
    });

    test('Max Abweichung Negative Werte', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      detector.x[0] = -1.2;
      detector.x[1] = -1.3;
      detector.x[2] = -1.4;
      detector.x[3] = -1.5;
      detector.x[4] = -1.2;
      detector.x[5] = -1.3;

      expect(detector.maxAbweichungZuMittelwert(-1.25), closeTo(0.25, accuracy));

      detector.index = 5;

      expect(detector.maxAbweichungZuMittelwert(-1.25), closeTo(0.15, accuracy));
    });

    test('Max Abweichung Negative Werte aber Positive Werte Im Mittel Fenster', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      detector.x[0] = -1.2;
      detector.x[1] = -1.3;
      detector.x[2] = 1.4;
      detector.x[3] = 1.5;
      detector.x[4] = -1.2;
      detector.x[5] = -1.3;

      expect(detector.maxAbweichungZuMittelwert(-1.25), closeTo(2.75, accuracy));
    });

    test('Peak', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isTrue);
    });

    test('Peak Lang', () {
      final detector = PeakDetector(20, 5, 0.05, 0.1, 0);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);

      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);

      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);

      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);
      expect(detector.update(0), isTrue);

      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
    });

    test('Peak Zu Klein', () {
      final detector = PeakDetector(6, 2, 0.1, 2, 0);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
    });

    test('Peak Differenz Mittelwert Zu Gross', () {
      final detector = PeakDetector(6, 2, 0.1, 0.1, 0);
      expect(detector.update(0), isFalse);
      expect(detector.update(0), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(1), isFalse);
      expect(detector.update(0.2), isFalse);
      expect(detector.update(0.1), isFalse);
    });

    test('Peak Im Border 1 Zu Gross', () {
      final detector = PeakDetector(9, 3, 2, 1, 0.05);
      expect(detector.update(0.1), isFalse);
      expect(detector.update(0.3), isFalse);
      expect(detector.update(0.1), isFalse);

      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);

      expect(detector.update(0.11), isFalse);
      expect(detector.update(0.12), isFalse);
      expect(detector.update(0.11), isFalse);
    });

    test('Peak Im Border 1 Zu Gross Positivtest', () {
      final detector = PeakDetector(9, 3, 2, 1, 0.5);
      expect(detector.update(0.1), isFalse);
      expect(detector.update(0.3), isFalse);
      expect(detector.update(0.1), isFalse);

      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);

      expect(detector.update(0.11), isFalse);
      expect(detector.update(0.12), isFalse);
      expect(detector.update(0.11), isTrue);
    });

    test('Peak Im Border 2 Zu Gross', () {
      final detector = PeakDetector(9, 3, 2, 1, 0.05);
      expect(detector.update(0.11), isFalse);
      expect(detector.update(0.12), isFalse);
      expect(detector.update(0.11), isFalse);

      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);

      expect(detector.update(0.1), isFalse);
      expect(detector.update(0.3), isFalse);
      expect(detector.update(0.1), isFalse);
    });

    test('Peak Im Border 2 Zu Gross Positivtest', () {
      final detector = PeakDetector(9, 3, 2, 1, 0.5);
      expect(detector.update(0.11), isFalse);
      expect(detector.update(0.12), isFalse);
      expect(detector.update(0.11), isFalse);

      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);
      expect(detector.update(2), isFalse);

      expect(detector.update(0.1), isFalse);
      expect(detector.update(0.3), isFalse);
      expect(detector.update(0.1), isTrue);
    });

    test('3D Init Length 0', () {
      expect(() => PeakDetector3D(0, 2, 0.1, 0.1, 0), throwsAssertionError);
    });

    test('3D Init Length 5 check array', () {
      final detector = PeakDetector3D(5, 2, 0, 0, 0);

      expect(detector.peakDetectorX.x, equals([0.0, 0.0, 0.0, 0.0, 0.0]));
      expect(detector.peakDetectorY.x, equals([0.0, 0.0, 0.0, 0.0, 0.0]));
      expect(detector.peakDetectorZ.x, equals([0.0, 0.0, 0.0, 0.0, 0.0]));
    });

    test('3D Init Length 5 check array after reset', () {
      final detector = PeakDetector3D(5, 2, 0, 0, 0);
      detector.resetWithXYZ(1, 2, 3);

      expect(detector.peakDetectorX.x, equals([1.0, 1.0, 1.0, 1.0, 1.0]));
      expect(detector.peakDetectorY.x, equals([2.0, 2.0, 2.0, 2.0, 2.0]));
      expect(detector.peakDetectorZ.x, equals([3.0, 3.0, 3.0, 3.0, 3.0]));
    });

    test('3D Or', () {
      final detector = PeakDetector3D(3, 1, 0.1, 2, 0);

      // Schlägt nicht an: kein Peak über Schwelle
      expect(detector.updateXYZ(1, 1, 1), isFalse);
      expect(detector.updateXYZ(1, 1, 1), isFalse);
      expect(detector.updateXYZ(1, 1, 1), isFalse);

      // Schlägt an: ein Peak über Schwelle
      expect(detector.updateXYZ(1, 1, 1), isFalse);
      expect(detector.updateXYZ(1, 5.1, 1), isFalse);
      expect(detector.updateXYZ(1, 1, 5.1), isTrue);

      // Hier muss es anschlagen, da die Z-Achse nun über der Schwelle ist
      expect(detector.updateXYZ(1, 1, 1), isTrue);
      expect(detector.updateXYZ(1, 1, 1), isFalse);
    });
  });
}
