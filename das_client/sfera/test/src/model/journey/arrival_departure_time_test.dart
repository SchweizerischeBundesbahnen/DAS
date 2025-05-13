import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/arrival_departure_time.dart';

void main() {
  test('primaryDepartureTime_whenOperationalDepartureTimeIsProvided_thenReturnsOperationalDepartureTime', () {
    final operationalDepartureTime = DateTime(2025, 5, 13, 10, 0);
    final plannedDepartureTime = DateTime(2025, 5, 13, 12, 0);
    final time = ArrivalDepartureTime(
      operationalDepartureTime: operationalDepartureTime,
      plannedDepartureTime: plannedDepartureTime,
    );

    expect(time.primaryDepartureTime, operationalDepartureTime);
  });

  test('primaryDepartureTime_whenBothOperationalAndPlannedDepartureTimesAreNull_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: null,
      plannedDepartureTime: null,
    );

    expect(time.primaryDepartureTime, isNull);
  });

  test('primaryDepartureTime_whenOperationalDepartureTimeIsNull_thenReturnsPlannedDepartureTime', () {
    final plannedDepartureTime = DateTime(2025, 5, 13, 12, 0);
    final time = ArrivalDepartureTime(
      operationalDepartureTime: null,
      plannedDepartureTime: plannedDepartureTime,
    );

    expect(time.primaryDepartureTime, plannedDepartureTime);
  });

  test('primaryArrivalTime_whenOperationalArrivalTimeIsProvided_thenReturnsOperationalArrivalTime', () {
    final operationalArrivalTime = DateTime(2025, 5, 13, 15, 0);
    final plannedArrivalTime = DateTime(2025, 5, 13, 16, 0);
    final time = ArrivalDepartureTime(
      operationalArrivalTime: operationalArrivalTime,
      plannedArrivalTime: plannedArrivalTime,
    );

    expect(time.primaryArrivalTime, operationalArrivalTime);
  });

  test('primaryArrivalTime_whenBothOperationalAndPlannedArrivalTimesAreNull_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      operationalArrivalTime: null,
      plannedArrivalTime: null,
    );

    expect(time.primaryArrivalTime, isNull);
  });

  test('primaryArrivalTime_whenOperationalArrivalTimeIsNull_thenReturnsPlannedArrivalTime', () {
    final plannedArrivalTime = DateTime(2025, 5, 13, 16, 0);
    final time = ArrivalDepartureTime(
      operationalArrivalTime: null,
      plannedArrivalTime: plannedArrivalTime,
    );

    expect(time.primaryArrivalTime, plannedArrivalTime);
  });

  test('secondaryDepartureTime_whenBothOperationalAndPlannedDepartureTimesAreNull_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: null,
      plannedDepartureTime: null,
    );

    expect(time.secondaryDepartureTime, isNull);
  });

  test('secondaryArrivalTime_whenBothOperationalAndPlannedArrivalTimesAreNull_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      operationalArrivalTime: null,
      plannedArrivalTime: null,
    );

    expect(time.secondaryArrivalTime, isNull);
  });

  test('hasCalculatedTimes_whenPlannedDepartureTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.hasCalculatedTimes, isTrue);
  });

  test('hasCalculatedTimes_whenPlannedArrivalTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.hasCalculatedTimes, isTrue);
  });

  test('hasCalculatedTimes_whenNeitherPlannedNorOperationalTimesAreProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      operationalDepartureTime: null,
      plannedDepartureTime: null,
      operationalArrivalTime: null,
      plannedArrivalTime: null,
    );

    expect(time.hasCalculatedTimes, isFalse);
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
