import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/comparator/start_end_int_comparator.dart';

void main() {
  group('StartEndIntComparator', () {
    test('compare_whenBothHaveEqualStartAndEnd_thenReturnsZero', () {
      // GIVEN
      final a = (start: 10, end: 20);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenFirstStartIsLess_thenReturnsNegative', () {
      // GIVEN
      final a = (start: 5, end: 20);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenFirstStartIsGreater_thenReturnsPositive', () {
      // GIVEN
      final a = (start: 15, end: 20);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenStartsAreEqualButFirstEndIsLess_thenReturnsNegative', () {
      // GIVEN
      final a = (start: 10, end: 15);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenStartsAreEqualButFirstEndIsGreater_thenReturnsPositive', () {
      // GIVEN
      final a = (start: 10, end: 25);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    // Edge cases with null values
    test('compare_whenFirstStartIsNull_thenReturnsNegative', () {
      // GIVEN
      final a = (start: null, end: 20);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenSecondStartIsNull_thenReturnsPositive', () {
      // GIVEN
      final a = (start: 10, end: 20);
      final b = (start: null, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenBothStartsAreNull_thenComparesEnds', () {
      // GIVEN
      final a = (start: null, end: 15);
      final b = (start: null, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenFirstEndIsNull_thenReturnsPositive', () {
      // GIVEN
      final a = (start: 10, end: null);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenSecondEndIsNull_thenReturnsNegative', () {
      // GIVEN
      final a = (start: 10, end: 20);
      final b = (start: 10, end: null);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenBothStartAndEndsAreNull_thenReturnsZero', () {
      // GIVEN
      final a = (start: null, end: null);
      final b = (start: null, end: null);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenBothStartsEqualAndBothEndsNull_thenReturnsZero', () {
      // GIVEN
      final a = (start: 10, end: null);
      final b = (start: 10, end: null);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenBothStartsNullAndBothEndsEqual_thenReturnsZero', () {
      // GIVEN
      final a = (start: null, end: 20);
      final b = (start: null, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenOneHasNeitherStartNorEndAndOtherHasBoth_thenComparesCorrectly', () {
      // GIVEN
      final a = (start: null, end: null);
      final b = (start: 10, end: 20);

      // WHEN & THEN
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });
  });
}
