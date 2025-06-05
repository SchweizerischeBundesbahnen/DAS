import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/lage_aenderung_detector.dart';

const double accuracy = 0.00001;

void main() {
  group('LageAenderungDetector Tests', () {
    test('Init Window Length1 With 0', () {
      expect(() => LageAenderungDetector(0, 1, 10.0), throwsAssertionError);
    });

    test('Init Window Length2 With 0', () {
      expect(() => LageAenderungDetector(1, 0, 10.0), throwsAssertionError);
    });

    test('Init Length 6 check array', () {
      final detector = LageAenderungDetector(3, 3, 5.0);
      expect(detector.x, equals([0.0, 0.0, 0.0, 0.0, 0.0, 0.0]));
    });

    test('Mittelwert', () {
      final detector = LageAenderungDetector(3, 3, 5.0);
      detector.x[0] = 1.1;
      detector.x[1] = 1.2;
      detector.x[2] = 1.3;
      detector.x[3] = 1.5;
      detector.x[4] = 1.6;
      detector.x[5] = 1.7;

      expect(detector.calculateMittelwert1(), closeTo((1.1 + 1.2 + 1.3) / 3, accuracy));
      expect(detector.calculateMittelwert2(), closeTo((1.5 + 1.6 + 1.7) / 3, accuracy));

      detector.index = 1;

      expect(detector.calculateMittelwert1(), closeTo((1.2 + 1.3 + 1.5) / 3, accuracy));
      expect(detector.calculateMittelwert2(), closeTo((1.6 + 1.7 + 1.1) / 3, accuracy));
    });

    test('Mittelwert ungleiche Laengen', () {
      final detector = LageAenderungDetector(2, 4, 5.0);
      detector.x[0] = 1.1;
      detector.x[1] = 1.2;
      detector.x[2] = 1.3;
      detector.x[3] = 1.5;
      detector.x[4] = 1.6;
      detector.x[5] = 1.7;

      expect(detector.calculateMittelwert1(), closeTo((1.1 + 1.2) / 2, accuracy));
      expect(detector.calculateMittelwert2(), closeTo((1.3 + 1.5 + 1.6 + 1.7) / 4, accuracy));

      detector.index = 1;

      expect(detector.calculateMittelwert1(), closeTo((1.2 + 1.3) / 2, accuracy));
      expect(detector.calculateMittelwert2(), closeTo((1.5 + 1.6 + 1.7 + 1.1) / 4, accuracy));
    });

    test('Update', () {
      final detector = LageAenderungDetector(3, 3, 1.5);

      expect(detector.update(0.1), isFalse);
      expect(detector.update(0.2), isFalse);
      expect(detector.update(0.3), isFalse);
      expect(detector.update(2.1), isFalse);
      expect(detector.update(2.2), isFalse);
      expect(detector.update(2.3), isTrue);
      expect(detector.update(2.2), isFalse);
      expect(detector.update(2.1), isFalse);
      expect(detector.update(2.2), isFalse);
      expect(detector.update(2.3), isFalse);
    });

    test('Update darf Erst Nach Vollem Buffer Zuschlagen', () {
      final detector = LageAenderungDetector(3, 3, 1.5);

      expect(detector.update(3.1), isFalse);
      expect(detector.update(3.2), isFalse);
      expect(detector.update(3.3), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.2), isFalse);
      expect(detector.update(1.3), isTrue);
      expect(detector.update(1.2), isFalse);
      expect(detector.update(1.1), isFalse);
      expect(detector.update(1.2), isFalse);
      expect(detector.update(1.3), isFalse);
    });

    test('Update 3D alle Werte Unter Schwelle', () {
      final detector = LageAenderungDetector3D(3, 3, 2.5);

      expect(detector.updateXYZ(0.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(0.2, 0.2, 0.2), isFalse);
      expect(detector.updateXYZ(0.3, 0.3, 0.3), isFalse);
      expect(detector.updateXYZ(2.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.2, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.2, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 0.1, 0.1), isFalse);
    });

    test('Update 3D ein Wert Ueber Schwelle', () {
      final detector = LageAenderungDetector3D(3, 3, 1.5);

      expect(detector.updateXYZ(0.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(0.2, 0.2, 0.2), isFalse);
      expect(detector.updateXYZ(0.3, 0.3, 0.3), isFalse);
      expect(detector.updateXYZ(2.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.2, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.2, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 0.1, 0.1), isFalse);
    });

    test('Update 3D zwei Werte Ueber Schwelle', () {
      final detector = LageAenderungDetector3D(3, 3, 1.5);

      expect(detector.updateXYZ(0.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(0.2, 0.2, 0.2), isFalse);
      expect(detector.updateXYZ(0.3, 0.3, 0.3), isFalse);
      expect(detector.updateXYZ(2.1, 2.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.2, 2.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 2.1, 0.1), isTrue);
      expect(detector.updateXYZ(2.2, 2.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.1, 2.1, 0.1), isFalse);
      expect(detector.updateXYZ(2.3, 2.1, 0.1), isFalse);
    });

    test('Update 3D drei Werte Ueber Schwelle', () {
      final detector = LageAenderungDetector3D(3, 3, 1.5);

      expect(detector.updateXYZ(0.1, 0.1, 0.1), isFalse);
      expect(detector.updateXYZ(0.2, 0.2, 0.2), isFalse);
      expect(detector.updateXYZ(0.3, 0.3, 0.3), isFalse);
      expect(detector.updateXYZ(2.1, 2.1, 2.1), isFalse);
      expect(detector.updateXYZ(2.2, 2.1, 2.1), isFalse);
      expect(detector.updateXYZ(2.3, 2.1, 2.1), isTrue);
      expect(detector.updateXYZ(2.2, 2.1, 2.1), isFalse);
      expect(detector.updateXYZ(2.1, 2.2, 2.1), isFalse);
      expect(detector.updateXYZ(2.3, 2.1, 2.1), isFalse);
    });
  });
}
