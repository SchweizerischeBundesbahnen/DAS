import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/delay.dart';

main() {
  group('Delay Tests', () {
    test('Init Length 0', () {
      expect(() => Delay(0), throwsAssertionError);
    });

    test('Init Length 5 check array', () {
      final filter = Delay(5);
      expect(filter.x[0], equals(0));
      expect(filter.x[1], equals(0));
      expect(filter.x[2], equals(0));
      expect(filter.x[3], equals(0));
      expect(filter.x[4], equals(0));
    });

    test('Init Length 5 check array after reset', () {
      final filter = Delay(5);
      filter.resetWithNewSample(1);

      expect(filter.x[0], equals(1));
      expect(filter.x[1], equals(1));
      expect(filter.x[2], equals(1));
      expect(filter.x[3], equals(1));
      expect(filter.x[4], equals(1));
    });

    test('Impuls', () {
      final filter = Delay(5);

      expect(filter.updateWithNewSample(0), equals(0.0));
      expect(filter.updateWithNewSample(0), equals(0.0));
      expect(filter.updateWithNewSample(0), equals(0.0));
      expect(filter.updateWithNewSample(1), equals(0.0));
      expect(filter.updateWithNewSample(2), equals(0.0));
      expect(filter.updateWithNewSample(3), equals(0.0));
      expect(filter.updateWithNewSample(4), equals(0.0));
      expect(filter.updateWithNewSample(5), equals(0.0));
      expect(filter.updateWithNewSample(6), equals(1.0));
      expect(filter.updateWithNewSample(7), equals(2.0));
      expect(filter.updateWithNewSample(8), equals(3.0));
      expect(filter.updateWithNewSample(9), equals(4.0));
    });

    test('Reset', () {
      final filter = Delay(5);

      expect(filter.resetWithNewSample(3), equals(3.0));
      expect(filter.updateWithNewSample(1), equals(3.0));
      expect(filter.updateWithNewSample(2), equals(3.0));
      expect(filter.updateWithNewSample(3), equals(3.0));
      expect(filter.updateWithNewSample(4), equals(3.0));
      expect(filter.updateWithNewSample(5), equals(3.0));
      expect(filter.updateWithNewSample(6), equals(1.0));
      expect(filter.updateWithNewSample(7), equals(2.0));
      expect(filter.updateWithNewSample(8), equals(3.0));
      expect(filter.updateWithNewSample(9), equals(4.0));
      expect(filter.updateWithNewSample(10), equals(5.0));
      expect(filter.updateWithNewSample(11), equals(6.0));
      expect(filter.updateWithNewSample(12), equals(7.0));
    });
  });
}
