import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/arrival_departure_time.dart';

void main() {
  test('operationalDepartureTime_whenOnlyPlannedDepartureTimeIsProvided_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.operationalDepartureTime, isNull);
  });

  test('operationalDepartureTime_whenOnlyAmbiguousDepartureTimeIsProvided_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.operationalDepartureTime, isNull);
  });

  test('operationalDepartureTime_whenBothAmbiguousAndPlannedDepartureTimesAreProvided_thenReturnsAmbiguousTime', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
      plannedDepartureTime: DateTime(2025, 5, 13, 11, 0),
    );

    expect(time.operationalDepartureTime, DateTime(2025, 5, 13, 12, 0));
  });

  test('plannedDepartureTime_whenOnlyPlannedDepartureTimeIsProvided_thenReturnsPlannedDepartureTime', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.plannedDepartureTime, DateTime(2025, 5, 13, 12, 0));
  });

  test('plannedDepartureTime_whenOnlyAmbiguousDepartureTimeIsProvided_thenReturnsAmbiguousTime', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.plannedDepartureTime, DateTime(2025, 5, 13, 12, 0));
  });

  test('plannedDepartureTime_whenBothAmbiguousAndPlannedDepartureTimesAreProvided_thenReturnsPlannedDepartureTime', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
      plannedDepartureTime: DateTime(2025, 5, 13, 11, 0),
    );

    expect(time.plannedDepartureTime, DateTime(2025, 5, 13, 11, 0));
  });

  test('operationalArrivalTime_whenOnlyPlannedArrivalTimeIsProvided_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.operationalArrivalTime, isNull);
  });

  test('operationalArrivalTime_whenOnlyAmbiguousArrivalTimeIsProvided_thenReturnsNull', () {
    final time = ArrivalDepartureTime(
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.operationalArrivalTime, isNull);
  });

  test('operationalArrivalTime_whenBothAmbiguousAndPlannedArrivalTimesAreProvided_thenReturnsAmbiguous', () {
    final time = ArrivalDepartureTime(
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.operationalArrivalTime, DateTime(2025, 5, 13, 15, 0));
  });

  test('plannedArrivalTime_whenOnlyPlannedArrivalTimeIsProvided_thenReturnsPlannedArrivalTime', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.plannedArrivalTime, DateTime(2025, 5, 13, 16, 0));
  });

  test('plannedArrivalTime_whenOnlyAmbiguousArrivalTimeIsProvided_thenReturnsAmbiguousArrivalTime', () {
    final time = ArrivalDepartureTime(
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.plannedArrivalTime, DateTime(2025, 5, 13, 15, 0));
  });

  test('plannedArrivalTime_whenBothAmbiguousAndPlannedArrivalTimesAreProvided_thenReturnsPlannedTime', () {
    final time = ArrivalDepartureTime(
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.plannedArrivalTime, DateTime(2025, 5, 13, 16, 0));
  });

  test('hasAnyTime_whenNoTime_thenReturnsFalse', () {
    final time = ArrivalDepartureTime();

    expect(time.hasAnyTime, isFalse);
  });

  test('hasAnyTime_whenSingleTime_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.hasAnyTime, isTrue);
  });

  test('hasAnyTime_whenTwoTimes_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
      plannedDepartureTime: DateTime(2025, 5, 13, 11, 0),
    );

    expect(time.hasAnyTime, isTrue);
  });

  test('hasAnyOperationalTime_whenOnlyPlannedDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.hasAnyOperationalTime, isFalse);
  });

  test('hasAnyOperationalTime_whenOnlyAmbiguousDepartureTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 12, 0),
    );

    expect(time.hasAnyOperationalTime, isFalse);
  });

  test('hasAnyOperationalTime_whenPlannedAndAmbiguousDepartureTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
      ambiguousDepartureTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.hasAnyOperationalTime, isTrue);
  });

  test('hasAnyOperationalTime_whenOnlyPlannedArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(time.hasAnyOperationalTime, isFalse);
  });

  test('hasAnyOperationalTime_whenOnlyAmbiguousArrivalTimeIsProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.hasAnyOperationalTime, isFalse);
  });

  test('hasAnyOperationalTime_whenPlannedAndAmbiguousArrivalTimeIsProvided_thenReturnsTrue', () {
    final time = ArrivalDepartureTime(
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
    );

    expect(time.hasAnyOperationalTime, isTrue);
  });

  test('hasAnyOperationalTime_whenNeitherPlannedNorAmbiguousTimesAreProvided_thenReturnsFalse', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: null,
      plannedDepartureTime: null,
      ambiguousArrivalTime: null,
      plannedArrivalTime: null,
    );

    expect(time.hasAnyOperationalTime, isFalse);
  });

  test('toString_whenCalled_thenReturnsCorrectStringRepresentation', () {
    final time = ArrivalDepartureTime(
      ambiguousDepartureTime: DateTime(2025, 5, 13, 10, 0),
      plannedDepartureTime: DateTime(2025, 5, 13, 12, 0),
      ambiguousArrivalTime: DateTime(2025, 5, 13, 15, 0),
      plannedArrivalTime: DateTime(2025, 5, 13, 16, 0),
    );

    expect(
      time.toString(),
      'ArrivalDepartureTime(operationalDepartureTime: 2025-05-13 10:00:00.000, plannedDepartureTime: 2025-05-13 12:00:00.000, operationalArrivalTime: 2025-05-13 15:00:00.000, plannedArrivalTime: 2025-05-13 16:00:00.000)',
    );
  });
}
