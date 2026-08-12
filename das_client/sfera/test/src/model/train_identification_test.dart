import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainIdentification', () {
    late DateTime now;
    late DateTime inFiveHours;
    late DateTime tomorrow;

    setUp(() {
      now = DateTime(1970, 1, 1);
      inFiveHours = now.add(Duration(hours: 5));
      tomorrow = DateTime.now().add(Duration(days: 1));
    });

    test('equals_whenSameProperties_thenReturnsTrue', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isTrue);
    });

    test('equals_whenDifferentRu_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '2185',
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenDifferentTrainNumber_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '1285',
        trainNumber: '5678',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenDifferentDay_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: tomorrow,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenOnSameDay_thenReturnsTrue', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: inFiveHours,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isTrue);
    });

    test('hashCode_whenSameProperties_thenReturnsSameHashCode', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA.hashCode, equals(testeeB.hashCode));
    });

    test('hashCode_whenDifferentProperties_thenReturnsDifferentHashCode', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        companyCode: '1285',
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        companyCode: '2185',
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA.hashCode == testeeB.hashCode, isFalse);
    });
  });
}
