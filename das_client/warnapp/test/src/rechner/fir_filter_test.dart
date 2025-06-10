import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/fir_filter.dart';

const double accuracy = 0.001;
const double value1 = 0.035714;
const double value2 = 0.276786;
const double value3 = 0.723214;
const double value4 = 0.964286;
const double value5 = 1.0;

void main() {
  group('FIRFilter Tests', () {
    test('Init Length 5', () {
      final hammingFilter = FIRFilter(5);

      expect(hammingFilter.getFIRCoef(0), closeTo(0.035, accuracy));
      expect(hammingFilter.getFIRCoef(1), closeTo(0.241, accuracy));
      expect(hammingFilter.getFIRCoef(2), closeTo(0.446, accuracy));
      expect(hammingFilter.getFIRCoef(3), closeTo(0.241, accuracy));
      expect(hammingFilter.getFIRCoef(4), closeTo(0.035, accuracy));
    });

    test('Length 5', () {
      final hammingFilter = FIRFilter(5);

      // Anstieg auf 1
      expect(hammingFilter.updateWithNewSample(1), closeTo(value1, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value2, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value3, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value4, accuracy));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));

      // Bleiben bei 1
      expect(hammingFilter.updateWithNewSample(1), equals(value5));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));

      // Anstieg auf 2
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value1, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value2, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value3, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value4, accuracy));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));

      // Bleiben bei 2
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
    });

    test('Length 5 resetOnFirstUpdate NO', () {
      final hammingFilter = FIRFilter(5, resetOnFirstUpdate: false);

      // Anstieg auf 1
      expect(hammingFilter.updateWithNewSample(1), closeTo(value1, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value2, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value3, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value4, accuracy));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));

      // Bleiben bei 1
      expect(hammingFilter.updateWithNewSample(1), equals(value5));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));
      expect(hammingFilter.updateWithNewSample(1), equals(value5));

      // Anstieg auf 2
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value1, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value2, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value3, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value4, accuracy));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));

      // Bleiben bei 2
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
      expect(hammingFilter.updateWithNewSample(2), equals(1.0 + value5));
    });

    test('Reset', () {
      final hammingFilter = FIRFilter(5);

      // mitten im Anstieg auf 1
      expect(hammingFilter.updateWithNewSample(1), closeTo(value1, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value2, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(value3, accuracy));

      // mit neuen Wert resetten
      expect(hammingFilter.resetWithNewSample(2.0), equals(2.0));
      expect(hammingFilter.resetWithNewSample(2.1), equals(2.1));
      expect(hammingFilter.resetWithNewSample(2.2), equals(2.2));
      expect(hammingFilter.resetWithNewSample(2.3), equals(2.3));
      expect(hammingFilter.resetWithNewSample(2.0), equals(2.0));

      // danach geht's normal weiter zurück zu 1
      expect(hammingFilter.updateWithNewSample(1), closeTo(1.0 + value4, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(1.0 + value3, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(1.0 + value2, accuracy));
      expect(hammingFilter.updateWithNewSample(1), closeTo(1.0 + value1, accuracy));
      expect(hammingFilter.updateWithNewSample(1), equals(1.0));
      expect(hammingFilter.updateWithNewSample(1), equals(1.0));
      expect(hammingFilter.updateWithNewSample(1), equals(1.0));
    });

    test('Vector', () {
      final filter3d = FIRFilter3D(1);

      filter3d.resetWithXYZ(1, 2, 3);

      expect(filter3d.x, closeTo(1, 0.000001));
      expect(filter3d.y, closeTo(2, 0.000001));
      expect(filter3d.z, closeTo(3, 0.000001));
    });

    test('Length 5 resetOnFirstUpdate YES', () {
      final hammingFilter = FIRFilter(5, resetOnFirstUpdate: true);

      // Erstes Update initialisiert Filter auf 1
      expect(hammingFilter.updateWithNewSample(1), closeTo(1, accuracy));

      // danach geht's normal weiter bis auf 2
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value1, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value2, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value3, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value4, accuracy));
      expect(hammingFilter.updateWithNewSample(2), closeTo(1.0 + value5, accuracy));
    });
  });
}
