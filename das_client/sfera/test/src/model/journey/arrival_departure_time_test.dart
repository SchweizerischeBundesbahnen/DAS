import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/arrival_departure_time.dart';

void main() {
  test('isDepartureTimeCalculated_whenOnlyPlannedDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.isDepartureTimeCalculated, isFalse);
  });

  test('isDepartureTimeCalculated_whenOnlyOperationalDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.isDepartureTimeCalculated, isFalse);
  });

  test('isDepartureTimeCalculated_whenBothOperationalAndPlannedDepartureTimesAreProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
      operationalDepartureTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.isDepartureTimeCalculated, isTrue);
  });

  test('isArrivalTimeCalculated_whenOnlyPlannedArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.isArrivalTimeCalculated, isFalse);
  });

  test('isArrivalTimeCalculated_whenOnlyOperationalArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.isArrivalTimeCalculated, isFalse);
  });

  test('isArrivalTimeCalculated_whenBothOperationalAndPlannedArrivalTimesAreProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
      operationalArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.isArrivalTimeCalculated, isTrue);
  });

  test('anyCalculatedTimes_whenOnlyPlannedDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.anyCalculatedTimes, isFalse);
  });

  test('anyCalculatedTimes_whenOnlyOperationalDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.anyCalculatedTimes, isFalse);
  });

  test('anyCalculatedTimes_whenPlannedAndOpDepartureTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
      operationalDepartureTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.anyCalculatedTimes, isTrue);
  });

  test('anyCalculatedTimes_whenOnlyPlannedArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.anyCalculatedTimes, isFalse);
  });

  test('anyCalculatedTimes_whenOnlyOperationalArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.anyCalculatedTimes, isFalse);
  });

  test('anyCalculatedTimes_whenPlannedAndOpArrivalTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
      operationalArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.anyCalculatedTimes, isTrue);
  });

  test('anyCalculatedTimes_whenNeitherPlannedNorOperationalTimesAreProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: null,
      plannedDepartureTime: null,
      operationalArrivalTime: null,
      plannedArrivalTime: null,
    );

    expect(time.anyCalculatedTimes, isFalse);
  });

  test('toString_whenCalled_thenReturnsCorrectStringRepresentation', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: DateTime(2025, 5, 13, 10, 0),
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
      operationalArrivalTime: DateTime(2025, 5, 13, 15, 0),
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.toString(),
        'ArrivalDepartureTime(operationalDepartureTime: 2025-05-13 10:00:00.000, plannedDepartureTime: 2025-05-13 12:00:00.000, operationalArrivalTime: 2025-05-13 15:00:00.000, plannedArrivalTime: 2025-05-13 16:00:00.000)');
  });
}
