import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/variance.dart';

const double accuracy = 0.00001;

void main() {
  group('Variance Tests', () {
    test('Init Length 0', () {
      expect(() => Variance(0), throwsAssertionError);
    });

    test('Init Length 5 check array', () {
      final filter = Variance(5);
      expect(filter.x[0], equals(0));
      expect(filter.x[1], equals(0));
      expect(filter.x[2], equals(0));
      expect(filter.x[3], equals(0));
      expect(filter.x[4], equals(0));
    });

    test('Init Length 5 check array after reset', () {
      final filter = Variance(5);
      filter.resetWithNewSample(1);

      expect(filter.x[0], equals(1));
      expect(filter.x[1], equals(1));
      expect(filter.x[2], equals(1));
      expect(filter.x[3], equals(1));
      expect(filter.x[4], equals(1));
    });

    test('Update with same values', () {
      final filter = Variance(5);

      expect(filter.updateWithNewSample(1), closeTo(0.2, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.2, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
    });

    test('Update with same values first reset', () {
      final filter = Variance(5);

      expect(filter.resetWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.0, accuracy));
    });

    test('Update with different values', () {
      final filter = Variance(5);

      expect(filter.updateWithNewSample(1), closeTo(0.2, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.8, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.7, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.7, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
    });

    test('Update with different values first reset', () {
      final filter = Variance(5);

      expect(filter.resetWithNewSample(1), closeTo(0.0, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.2, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.2, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(2), closeTo(0.3, accuracy));
      expect(filter.updateWithNewSample(1), closeTo(0.3, accuracy));
    });
  });

  group('Variance3D Tests', () {
    test('3D Init Length 0', () {
      expect(() => Variance3D(0), throwsAssertionError);
    });

    test('3D Init Length 5 check array', () {
      final filter = Variance3D(5);
      expect(filter.varianceX.x[0], equals(0));
      expect(filter.varianceX.x[1], equals(0));
      expect(filter.varianceX.x[2], equals(0));
      expect(filter.varianceX.x[3], equals(0));
      expect(filter.varianceX.x[4], equals(0));
      expect(filter.varianceY.x[0], equals(0));
      expect(filter.varianceY.x[1], equals(0));
      expect(filter.varianceY.x[2], equals(0));
      expect(filter.varianceY.x[3], equals(0));
      expect(filter.varianceY.x[4], equals(0));
      expect(filter.varianceZ.x[0], equals(0));
      expect(filter.varianceZ.x[1], equals(0));
      expect(filter.varianceZ.x[2], equals(0));
      expect(filter.varianceZ.x[3], equals(0));
      expect(filter.varianceZ.x[4], equals(0));
    });

    test('3D Init Length 5 check array after reset', () {
      final filter = Variance3D(5);
      filter.resetWithX(1, 2, 3);

      expect(filter.varianceX.x[0], equals(1));
      expect(filter.varianceX.x[1], equals(1));
      expect(filter.varianceX.x[2], equals(1));
      expect(filter.varianceX.x[3], equals(1));
      expect(filter.varianceX.x[4], equals(1));
      expect(filter.varianceY.x[0], equals(2));
      expect(filter.varianceY.x[1], equals(2));
      expect(filter.varianceY.x[2], equals(2));
      expect(filter.varianceY.x[3], equals(2));
      expect(filter.varianceY.x[4], equals(2));
      expect(filter.varianceZ.x[0], equals(3));
      expect(filter.varianceZ.x[1], equals(3));
      expect(filter.varianceZ.x[2], equals(3));
      expect(filter.varianceZ.x[3], equals(3));
      expect(filter.varianceZ.x[4], equals(3));
    });

    test('3D Summe', () {
      final filter = Variance3D(5);

      filter.varianceX.value = 1;
      filter.varianceY.value = 1;
      filter.varianceZ.value = 1;

      expect(filter.summe(), closeTo(3, accuracy));
    });

    test('3D Update with different values', () {
      final filter = Variance3D(5);

      filter.resetWithX(1, 2, 3);
      expect(filter.summe(), closeTo(0.0, accuracy));
      filter.updateX(2, 2, 3);
      expect(filter.summe(), closeTo(0.2, accuracy));
      filter.updateX(1, 2, 3);
      expect(filter.summe(), closeTo(0.2, accuracy));
      filter.updateX(2, 2, 3);
      expect(filter.summe(), closeTo(0.3, accuracy));
      filter.updateX(1, 2, 3);
      expect(filter.summe(), closeTo(0.3, accuracy));
      filter.updateX(2, 2, 3);
      expect(filter.summe(), closeTo(0.3, accuracy));
      filter.updateX(1, 2, 3);
      expect(filter.summe(), closeTo(0.3, accuracy));
      filter.updateX(2, 2, 3);
      expect(filter.summe(), closeTo(0.3, accuracy));
    });
  });
}
