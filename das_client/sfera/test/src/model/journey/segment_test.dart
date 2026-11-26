import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/segment.dart';

void main() {
  group('Segment', () {
    test('appliesToOrder_whenStartAndEndAreNull_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: null, endOrder: null);

      // WHEN & THEN
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOrderIsWithinStartAndEndRange_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOrderEqualsStart_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(5), isTrue);
    });

    test('appliesToOrder_whenOrderEqualsEnd_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(15), isTrue);
    });

    test('appliesToOrder_whenOrderIsLessThanStart_thenReturnsFalse', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(3), isFalse);
    });

    test('appliesToOrder_whenOrderIsGreaterThanEnd_thenReturnsFalse', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(20), isFalse);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderIsGreaterThanStart_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // WHEN & THEN
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderEqualsStart_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // WHEN & THEN
      expect(segment.appliesToOrder(5), isTrue);
    });

    test('appliesToOrder_whenOnlyStartIsDefinedAndOrderIsLessThanStart_thenReturnsFalse', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 5, endOrder: null);

      // WHEN & THEN
      expect(segment.appliesToOrder(3), isFalse);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderIsLessThanEnd_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(10), isTrue);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderEqualsEnd_thenReturnsTrue', () {
      // GIVEN
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(15), isTrue);
    });

    test('appliesToOrder_whenOnlyEndIsDefinedAndOrderIsGreaterThanEnd_thenReturnsFalse', () {
      // GIVEN
      final segment = _TestSegment(startOrder: null, endOrder: 15);

      // WHEN & THEN
      expect(segment.appliesToOrder(20), isFalse);
    });

    test('compareTo_whenOtherIsNotSegment_thenReturnsNegativeOne', () {
      // GIVEN
      final segment = _TestSegment(startOrder: 1, endOrder: 5);
      final other = 'not a segment';

      // WHEN
      final result = segment.compareTo(other);

      // THEN
      expect(result, -1);
    });
  });

  group('SegmentsExtension', () {
    test('appliesToOrder_whenCalledWithOrder_thenReturnsMatchingSegments', () {
      // GIVEN
      final segments = [
        _TestSegment(startOrder: 1, endOrder: 5),
        _TestSegment(startOrder: 3, endOrder: 8),
        _TestSegment(startOrder: 6, endOrder: 10),
      ];

      // WHEN
      final result = segments.appliesToOrder(4);

      // THEN
      expect(result.length, 2);
      expect(result.contains(segments[0]), isTrue);
      expect(result.contains(segments[1]), isTrue);
    });

    test('appliesToOrderRange_whenCalledWithRange_thenReturnsMatchingSegments', () {
      // GIVEN
      final segments = [
        _TestSegment(startOrder: 1, endOrder: 5),
        _TestSegment(startOrder: 3, endOrder: 8),
        _TestSegment(startOrder: 6, endOrder: 10),
      ];

      // WHEN
      final result = segments.appliesToOrderRange(4, 7);

      // THEN
      expect(result.length, 1);
      expect(result.contains(segments[1]), isTrue);
    });
  });
}

class const _TestSegment({
  super.startOrder,
  super.endOrder,
}) extends Segment;
