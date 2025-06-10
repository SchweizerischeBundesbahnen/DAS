import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/integrator.dart';

void main() {
  group('Integrator Tests', () {
    test('Init Length 5 Impuls', () {
      final filter = Integrator(5);

      expect(filter.update(0), equals(0.0));
      expect(filter.update(1), equals(1.0));
      expect(filter.update(0), equals(1.0));
      expect(filter.update(0), equals(1.0));
      expect(filter.update(0), equals(1.0));
      expect(filter.update(0), equals(1.0));
      expect(filter.update(0), equals(0.0));
    });

    test('Init Length 5 Values', () {
      final filter = Integrator(5);

      expect(filter.update(1), equals(1.0));
      expect(filter.update(2), equals(3.0));
      expect(filter.update(3), equals(6.0));
      expect(filter.update(4), equals(10.0));
      expect(filter.update(5), equals(15.0));
      expect(filter.update(5), equals(19.0));
      expect(filter.update(4), equals(21.0));
      expect(filter.update(3), equals(21.0));
      expect(filter.update(2), equals(19.0));
      expect(filter.update(1), equals(15.0));
      expect(filter.update(0), equals(10.0));
      expect(filter.update(0), equals(6.0));
      expect(filter.update(0), equals(3.0));
      expect(filter.update(0), equals(1.0));
      expect(filter.update(0), equals(0.0));
    });

    test('Init Length 5 Values Not Disabled', () {
      final filter = Integrator(5);

      expect(filter.updateWithNewSample(1, disabled: false), equals(1.0));
      expect(filter.updateWithNewSample(2, disabled: false), equals(3.0));
      expect(filter.updateWithNewSample(3, disabled: false), equals(6.0));
      expect(filter.updateWithNewSample(4, disabled: false), equals(10.0));
      expect(filter.updateWithNewSample(5, disabled: false), equals(15.0));
      expect(filter.updateWithNewSample(5, disabled: false), equals(19.0));
      expect(filter.updateWithNewSample(4, disabled: false), equals(21.0));
      expect(filter.updateWithNewSample(3, disabled: false), equals(21.0));
      expect(filter.updateWithNewSample(2, disabled: false), equals(19.0));
      expect(filter.updateWithNewSample(1, disabled: false), equals(15.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(10.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(6.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(3.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(1.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(0.0));
    });

    test('Init Length 5 Values Disabled', () {
      final filter = Integrator(5);

      expect(filter.updateWithNewSample(1, disabled: false), equals(1.0));
      expect(filter.updateWithNewSample(2, disabled: false), equals(3.0));
      expect(filter.updateWithNewSample(3, disabled: false), equals(6.0));
      expect(filter.updateWithNewSample(4, disabled: false), equals(10.0));
      expect(filter.updateWithNewSample(5, disabled: false), equals(15.0));
      expect(filter.updateWithNewSample(5, disabled: true), equals(15.0));
      expect(filter.updateWithNewSample(4, disabled: true), equals(15.0));
      expect(filter.updateWithNewSample(3, disabled: true), equals(15.0));
      expect(filter.updateWithNewSample(2, disabled: false), equals(16.0));
      expect(filter.updateWithNewSample(1, disabled: false), equals(15.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(12.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(8.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(3.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(1.0));
      expect(filter.updateWithNewSample(0, disabled: false), equals(0.0));
    });
  });
}
