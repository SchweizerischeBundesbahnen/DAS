import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/comparator/start_end_int_comparator.dart';

void main() {
  group('StartEndIntComparator', () {
    test('compare_whenBothHaveEqualStartAndEnd_thenReturnsZero', () {
      // ARRANGE
      final a = (start: 10, end: 20);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenFirstStartIsLess_thenReturnsNegative', () {
      // ARRANGE
      final a = (start: 5, end: 20);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenFirstStartIsGreater_thenReturnsPositive', () {
      // ARRANGE
      final a = (start: 15, end: 20);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenStartsAreEqualButFirstEndIsLess_thenReturnsNegative', () {
      // ARRANGE
      final a = (start: 10, end: 15);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenStartsAreEqualButFirstEndIsGreater_thenReturnsPositive', () {
      // ARRANGE
      final a = (start: 10, end: 25);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    // Edge cases with null values
    test('compare_whenFirstStartIsNull_thenReturnsNegative', () {
      // ARRANGE
      final a = (start: null, end: 20);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenSecondStartIsNull_thenReturnsPositive', () {
      // ARRANGE
      final a = (start: 10, end: 20);
      final b = (start: null, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenBothStartsAreNull_thenComparesEnds', () {
      // ARRANGE
      final a = (start: null, end: 15);
      final b = (start: null, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenFirstEndIsNull_thenReturnsPositive', () {
      // ARRANGE
      final a = (start: 10, end: null);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isPositive);
    });

    test('compare_whenSecondEndIsNull_thenReturnsNegative', () {
      // ARRANGE
      final a = (start: 10, end: 20);
      final b = (start: 10, end: null);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });

    test('compare_whenBothStartAndEndsAreNull_thenReturnsZero', () {
      // ARRANGE
      final a = (start: null, end: null);
      final b = (start: null, end: null);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenBothStartsEqualAndBothEndsNull_thenReturnsZero', () {
      // ARRANGE
      final a = (start: 10, end: null);
      final b = (start: 10, end: null);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenBothStartsNullAndBothEndsEqual_thenReturnsZero', () {
      // ARRANGE
      final a = (start: null, end: 20);
      final b = (start: null, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), equals(0));
    });

    test('compare_whenOneHasNeitherStartNorEndAndOtherHasBoth_thenComparesCorrectly', () {
      // ARRANGE
      final a = (start: null, end: null);
      final b = (start: 10, end: 20);

      // ACT & EXPECT
      expect(StartEndIntComparator.compare(a, b), isNegative);
    });
  });
}
