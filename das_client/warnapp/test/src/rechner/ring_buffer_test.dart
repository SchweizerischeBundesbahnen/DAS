import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/ring_buffer.dart';

void main() {
  group('WAPRingBuffer Tests', () {
    test('update Bulk', () {
      final b = RingBuffer(5, options: [RingBufferOptions.sum, RingBufferOptions.minMax]);

      withBuffer(b, 0, () {
        expect(b.sum, equals(0));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(0));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(0));
        expect(b.max, equals(0));
      });
      withBuffer(b, 1, () {
        expect(b.sum, equals(1));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(1));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(0));
        expect(b.max, equals(1));
      });
      withBuffer(b, 2, () {
        expect(b.sum, equals(3));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(2));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(0));
        expect(b.max, equals(2));
      });
      withBuffer(b, 3, () {
        expect(b.sum, equals(6));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(3));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(0));
        expect(b.max, equals(3));
      });
      withBuffer(b, 4, () {
        expect(b.sum, equals(10));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(4));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(0));
        expect(b.max, equals(4));
      });
      withBuffer(b, 5, () {
        expect(b.sum, equals(15));
        expect(b.firstValue, equals(1));
        expect(b.lastValue, equals(5));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(1));
        expect(b.max, equals(5));
      });
      withBuffer(b, 6, () {
        expect(b.sum, equals(20));
        expect(b.firstValue, equals(2));
        expect(b.lastValue, equals(6));
        expect(b.lastRemovedValue, equals(1));
        expect(b.min, equals(2));
        expect(b.max, equals(6));
      });
      withBuffer(b, 7, () {
        expect(b.sum, equals(25));
        expect(b.firstValue, equals(3));
        expect(b.lastValue, equals(7));
        expect(b.lastRemovedValue, equals(2));
        expect(b.min, equals(3));
        expect(b.max, equals(7));
      });
      withBuffer(b, 8, () {
        expect(b.sum, equals(30));
        expect(b.firstValue, equals(4));
        expect(b.lastValue, equals(8));
        expect(b.lastRemovedValue, equals(3));
        expect(b.min, equals(4));
        expect(b.max, equals(8));
      });
    });

    test('update Bulk Inited With 999', () {
      final b = RingBuffer(3, options: [RingBufferOptions.sum, RingBufferOptions.minMax]);

      b.reset(999);
      expect(b.sum, equals(999 * 3));
      expect(b.firstValue, equals(999));
      expect(b.lastValue, equals(999));
      expect(b.lastRemovedValue, equals(0));

      withBuffer(b, 0, () {
        expect(b.sum, equals(1998));
        expect(b.firstValue, equals(999));
        expect(b.lastValue, equals(0));
        expect(b.lastRemovedValue, equals(999));
        expect(b.min, equals(0));
        expect(b.max, equals(999));
      });
      withBuffer(b, 1, () {
        expect(b.sum, equals(1000));
        expect(b.firstValue, equals(999));
        expect(b.lastValue, equals(1));
        expect(b.lastRemovedValue, equals(999));
        expect(b.min, equals(0));
        expect(b.max, equals(999));
      });
      withBuffer(b, 2, () {
        expect(b.sum, equals(3));
        expect(b.firstValue, equals(0));
        expect(b.lastValue, equals(2));
        expect(b.lastRemovedValue, equals(999));
        expect(b.min, equals(0));
        expect(b.max, equals(2));
      });
      withBuffer(b, 3, () {
        expect(b.sum, equals(6));
        expect(b.firstValue, equals(1));
        expect(b.lastValue, equals(3));
        expect(b.lastRemovedValue, equals(0));
        expect(b.min, equals(1));
        expect(b.max, equals(3));
      });
      withBuffer(b, 4, () {
        expect(b.sum, equals(9));
        expect(b.firstValue, equals(2));
        expect(b.lastValue, equals(4));
        expect(b.lastRemovedValue, equals(1));
        expect(b.min, equals(2));
        expect(b.max, equals(4));
      });
      withBuffer(b, 5, () {
        expect(b.sum, equals(12));
        expect(b.firstValue, equals(3));
        expect(b.lastValue, equals(5));
        expect(b.lastRemovedValue, equals(2));
        expect(b.min, equals(3));
        expect(b.max, equals(5));
      });
      withBuffer(b, 6, () {
        expect(b.sum, equals(15));
        expect(b.firstValue, equals(4));
        expect(b.lastValue, equals(6));
        expect(b.lastRemovedValue, equals(3));
        expect(b.min, equals(4));
        expect(b.max, equals(6));
      });
      withBuffer(b, 7, () {
        expect(b.sum, equals(18));
        expect(b.firstValue, equals(5));
        expect(b.lastValue, equals(7));
        expect(b.lastRemovedValue, equals(4));
        expect(b.min, equals(5));
        expect(b.max, equals(7));
      });
      withBuffer(b, 8, () {
        expect(b.sum, equals(21));
        expect(b.firstValue, equals(6));
        expect(b.lastValue, equals(8));
        expect(b.lastRemovedValue, equals(5));
        expect(b.min, equals(6));
        expect(b.max, equals(8));
      });
    });

    test('min', () {
      final b = RingBuffer(3, options: [RingBufferOptions.minMax]);

      withBuffer(b, 0, () {
        expect(b.min, equals(0));
      });
      withBuffer(b, 1, () {
        expect(b.min, equals(0));
      });
      withBuffer(b, 2, () {
        expect(b.min, equals(0));
      });
      withBuffer(b, 1, () {
        expect(b.min, equals(1));
      });
      withBuffer(b, 0, () {
        expect(b.min, equals(0));
      });
      withBuffer(b, 7, () {
        expect(b.min, equals(0));
      });
      withBuffer(b, -5, () {
        expect(b.min, equals(-5));
      });
      withBuffer(b, 15, () {
        expect(b.min, equals(-5));
      });
      withBuffer(b, 0, () {
        expect(b.min, equals(-5));
      });
      withBuffer(b, 0, () {
        expect(b.min, equals(0));
      });
    });

    test('max', () {
      final b = RingBuffer(3, options: [RingBufferOptions.minMax]);

      withBuffer(b, 0, () {
        expect(b.max, equals(0));
      });
      withBuffer(b, 1, () {
        expect(b.max, equals(1));
      });
      withBuffer(b, 2, () {
        expect(b.max, equals(2));
      });
      withBuffer(b, 1, () {
        expect(b.max, equals(2));
      });
      withBuffer(b, 0, () {
        expect(b.max, equals(2));
      });
      withBuffer(b, 7, () {
        expect(b.max, equals(7));
      });
      withBuffer(b, -5, () {
        expect(b.max, equals(7));
      });
      withBuffer(b, 15, () {
        expect(b.max, equals(15));
      });
      withBuffer(b, 0, () {
        expect(b.max, equals(15));
      });
      withBuffer(b, 0, () {
        expect(b.max, equals(15));
      });
    });

    test('values', () {
      final b = RingBuffer(3);

      final array1 = [0, 0, 1];
      final array2 = [0, 1, 2];
      final array3 = [1, 2, 3];
      final array4 = [2, 3, 4];

      withBuffer(b, 1, () {
        expect(b.values(), equals(array1));
      });
      withBuffer(b, 2, () {
        expect(b.values(), equals(array2));
      });
      withBuffer(b, 3, () {
        expect(b.values(), equals(array3));
      });
      withBuffer(b, 4, () {
        expect(b.values(), equals(array4));
      });
    });

    test('stringWithFormat 0.1f and Delimiter', () {
      final b = RingBuffer(3);

      withBuffer(b, 1, () {
        expect(b.stringWithFormat(1, ','), equals('0.0,0.0,1.0'));
      });
      withBuffer(b, 2, () {
        expect(b.stringWithFormat(1, ','), equals('0.0,1.0,2.0'));
      });
      withBuffer(b, 0.3, () {
        expect(b.stringWithFormat(1, ','), equals('1.0,2.0,0.3'));
      });
      withBuffer(b, 0.4, () {
        expect(b.stringWithFormat(1, ','), equals('2.0,0.3,0.4'));
      });
    });

    test('stringWithFormat 1f and No Delimiter', () {
      final b = RingBuffer(3);

      withBuffer(b, 1, () {
        expect(b.stringWithFormat(0, ''), equals('001'));
      });
      withBuffer(b, 2, () {
        expect(b.stringWithFormat(0, ''), equals('012'));
      });
      withBuffer(b, 3, () {
        expect(b.stringWithFormat(0, ''), equals('123'));
      });
      withBuffer(b, 4, () {
        expect(b.stringWithFormat(0, ''), equals('234'));
      });
    });
  });
}

void withBuffer(RingBuffer ringBuffer, double value, void Function() assertBlock) {
  ringBuffer.update(value);
  assertBlock();
}
