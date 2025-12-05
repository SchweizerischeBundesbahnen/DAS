import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/train_identification.dart';

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
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isTrue);
    });

    test('equals_whenDifferentRu_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbC,
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenDifferentTrainNumber_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbP,
        trainNumber: '5678',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenDifferentDay_thenReturnsFalse', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: tomorrow,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isFalse);
    });

    test('equals_whenOnSameDay_thenReturnsTrue', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: inFiveHours,
      );

      // ACT & EXPECT
      expect(testeeA == testeeB, isTrue);
    });

    test('hashCode_whenSameProperties_thenReturnsSameHashCode', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA.hashCode, equals(testeeB.hashCode));
    });

    test('hashCode_whenDifferentProperties_thenReturnsDifferentHashCode', () {
      // ARRANGE
      final testeeA = TrainIdentification(
        ru: .sbbP,
        trainNumber: '1234',
        date: now,
      );
      final testeeB = TrainIdentification(
        ru: .sbbC,
        trainNumber: '1234',
        date: now,
      );

      // ACT & EXPECT
      expect(testeeA.hashCode == testeeB.hashCode, isFalse);
    });
  });
}
