import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/segment.dart';

void main() {
  group('Segment', () {
    test('appliesToOrder_whenStartAndEndAreNull_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: null, endOrder: null);

      // ACT & EXPECT
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOrderIsWithinStartAndEndRange_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOrderEqualsStart_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(5), isTrue);
    });

    test('appliesToOrder_whenOrderEqualsEnd_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(15), isTrue);
    });

    test('appliesToOrder_whenOrderIsLessThanStart_thenReturnsFalse', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(3), isFalse);
    });

    test('appliesToOrder_whenOrderIsGreaterThanEnd_thenReturnsFalse', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(20), isFalse);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderIsGreaterThanStart_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // ACT & EXPECT
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderEqualsStart_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // ACT & EXPECT
      expect(segment.appliesToOrder(5), isTrue);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderIsLessThanStart_thenReturnsFalse', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // ACT & EXPECT
      expect(segment.appliesToOrder(3), isFalse);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderIsLessThanEnd_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderEqualsEnd_thenReturnsTrue', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(15), isTrue);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderIsGreaterThanEnd_thenReturnsFalse', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // ACT & EXPECT
      expect(segment.appliesToOrder(20), isFalse);
    });

    test('compareTo_whenOtherIsNotSegment_thenReturnsNegativeOne', () {
      // ARRANGE
      final segment = _TestSegment(startOrder: 1, endOrder: 5);
      final other = 'not a segment';

      // ACT
      final result = segment.compareTo(other);

      // EXPECT
      expect(result, -1);
    });
  });

  group('SegmentsExtension', () {
    test('appliesToOrder_whenCalledWithOrder_thenReturnsMatchingSegments', () {
      // ARRANGE
      final segments = [
        _TestSegment(startOrder: 1, endOrder: 5),
        _TestSegment(startOrder: 3, endOrder: 8),
        _TestSegment(startOrder: 6, endOrder: 10),
      ];

      // ACT
      final result = segments.appliesToOrder(4);

      // EXPECT
      expect(result.length, 2);
      expect(result.contains(segments[0]), isTrue);
      expect(result.contains(segments[1]), isTrue);
    });

    test('appliesToOrderRange_whenCalledWithRange_thenReturnsMatchingSegments', () {
      // ARRANGE
      final segments = [
        _TestSegment(startOrder: 1, endOrder: 5),
        _TestSegment(startOrder: 3, endOrder: 8),
        _TestSegment(startOrder: 6, endOrder: 10),
      ];

      // ACT
      final result = segments.appliesToOrderRange(4, 7);

      // EXPECT
      expect(result.length, 1);
      expect(result.contains(segments[1]), isTrue);
    });
  });
}

class _TestSegment extends Segment {
  const _TestSegment({
    super.startOrder,
    super.endOrder,
  });
}
