import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/fahrt_hysterese.dart';

void main() {
  group('WAPFahrtHysterese Tests', () {
    late FahrtHysterese hysterese;

    test('Init Length 0', () {
      expect(() => FahrtHysterese(0, 0, 0), throwsAssertionError);
    });

    test('Init Length 5 check array', () {
      hysterese = FahrtHysterese(5, 0, 0);

      expect(hysterese.ringbuffer[0], equals(0));
      expect(hysterese.ringbuffer[1], equals(0));
      expect(hysterese.ringbuffer[2], equals(0));
      expect(hysterese.ringbuffer[3], equals(0));
      expect(hysterese.ringbuffer[4], equals(0));
    });

    test('Init Length 5 check array after reset', () {
      hysterese = FahrtHysterese(5, 0, 0);
      hysterese.reset(1);

      expect(hysterese.ringbuffer[0], equals(1));
      expect(hysterese.ringbuffer[1], equals(1));
      expect(hysterese.ringbuffer[2], equals(1));
      expect(hysterese.ringbuffer[3], equals(1));
      expect(hysterese.ringbuffer[4], equals(1));
    });

    test('Sequenz', () {
      hysterese = FahrtHysterese(3, 1, 2);

      expect(hysterese.update(0.9), isFalse);
      expect(hysterese.update(0.9), isFalse);
      expect(hysterese.update(1.1), isFalse);
      expect(hysterese.update(1.1), isTrue);
      expect(hysterese.update(0.9), isTrue);
      expect(hysterese.update(0.9), isFalse);
      expect(hysterese.update(1.1), isFalse);
      expect(hysterese.update(1.1), isTrue);
      expect(hysterese.update(1.1), isTrue);
      expect(hysterese.update(1.1), isTrue);
      expect(hysterese.update(0.9), isTrue);
      expect(hysterese.update(0.9), isFalse);
      expect(hysterese.update(0.9), isFalse);
      expect(hysterese.update(0.9), isFalse);
    });

    test('Abfahrt Ok', () {
      hysterese = FahrtHysterese(3, 1, 2);

      fillBuffer(hysterese, [1.1, 1.1, 0.9]);
      expect(hysterese.fahrt, isTrue);
    });

    test('Abfahrt Ok1', () {
      hysterese = FahrtHysterese(3, 1, 2);

      fillBuffer(hysterese, [1.1, 1.01, 1.01]);
      expect(hysterese.fahrt, isTrue);
    });

    test('Abfahrt NOk', () {
      hysterese = FahrtHysterese(3, 1, 2);

      fillBuffer(hysterese, [1.1, 0.9, 0.9]);
      expect(hysterese.fahrt, isFalse);
    });
  });
}

void fillBuffer(FahrtHysterese hysterese, List<double> values) {
  hysterese.reset(0);

  for (final value in values) {
    hysterese.update(value);
  }
}
