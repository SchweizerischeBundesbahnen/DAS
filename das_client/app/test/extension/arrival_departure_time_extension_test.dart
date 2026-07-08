import 'package:app/extension/arrival_departure_time_extension.dart';
import 'package:app/util/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('formattedTimes_whenArrivalDepartureTimeIsNull_thenReturnsEmptyValues', () {
    // GIVEN
    ArrivalDepartureTime? arrivalDepartureTime;

    // WHEN
    final formatted = arrivalDepartureTime.formattedTimes(
      showOperationalTime: false,
      showTimesInBrackets: false,
    );

    // THEN
    expect(formatted, ('', '', false, true));
  });

  test('formattedTimes_whenPlannedTimesAreShown_thenFormatsPlannedTimesAndUnderlinesDeparture', () {
    // GIVEN
    final plannedDeparture = DateTime(2026, 1, 1, 10, 15);
    final plannedArrival = DateTime(2026, 1, 1, 10, 30);
    final arrivalDepartureTime = ArrivalDepartureTime(
      plannedDepartureTime: plannedDeparture,
      plannedArrivalTime: plannedArrival,
    );

    // WHEN
    final formatted = arrivalDepartureTime.formattedTimes(
      showOperationalTime: false,
      showTimesInBrackets: false,
      currentTime: DateTime(2026, 1, 1, 10, 15, 59),
    );

    // THEN
    expect(formatted.$1, Format.plannedTime(plannedDeparture));
    expect(formatted.$2, '${Format.plannedTime(plannedArrival)}\n');
    expect(formatted.$3, isTrue);
    expect(formatted.$4, isTrue);
  });

  test('formattedTimes_whenOperationalTimesAreShown_thenFormatsOperationalTimes', () {
    // GIVEN
    final plannedDeparture = DateTime(2026, 1, 1, 10, 15);
    final plannedArrival = DateTime(2026, 1, 1, 10, 30);
    final operationalDeparture = DateTime(2026, 1, 1, 10, 16, 45);
    final operationalArrival = DateTime(2026, 1, 1, 10, 31, 40);
    final arrivalDepartureTime = ArrivalDepartureTime(
      ambiguousDepartureTime: operationalDeparture,
      plannedDepartureTime: plannedDeparture,
      ambiguousArrivalTime: operationalArrival,
      plannedArrivalTime: plannedArrival,
    );

    // WHEN
    final formatted = arrivalDepartureTime.formattedTimes(
      showOperationalTime: true,
      showTimesInBrackets: false,
      currentTime: DateTime(2026, 1, 1, 10, 20),
    );

    // THEN
    expect(formatted.$1, Format.operationalTime(operationalDeparture));
    expect(formatted.$2, '${Format.operationalTime(operationalArrival)}\n');
    expect(formatted.$3, isTrue);
    expect(formatted.$4, isTrue);
  });

  test('formattedTimes_whenTimesInBracketsIsTrue_thenWrapsDisplayedTimesInBrackets', () {
    // GIVEN
    final plannedDeparture = DateTime(2026, 1, 1, 10, 15);
    final plannedArrival = DateTime(2026, 1, 1, 10, 30);
    final arrivalDepartureTime = ArrivalDepartureTime(
      plannedDepartureTime: plannedDeparture,
      plannedArrivalTime: plannedArrival,
    );

    // WHEN
    final formatted = arrivalDepartureTime.formattedTimes(
      showOperationalTime: false,
      showTimesInBrackets: true,
      currentTime: DateTime(2026, 1, 1, 10, 10),
    );

    // THEN
    expect(formatted.$1, '(${Format.plannedTime(plannedDeparture)})');
    expect(formatted.$2, '(${Format.plannedTime(plannedArrival)})\n');
    expect(formatted.$3, isFalse);
    expect(formatted.$4, isTrue);
  });

  test('formattedTimes_whenOnlyPlannedReleaseTimeExists_thenForcesBracketAndNotStyledAsBold', () {
    // GIVEN
    final plannedArrival = DateTime(2026, 1, 1, 10, 30);
    final plannedReleasedTime = DateTime(2026, 1, 1, 10, 20);
    final arrivalDepartureTime = ArrivalDepartureTime(
      plannedArrivalTime: plannedArrival,
      plannedReleasedTime: plannedReleasedTime,
    );

    // WHEN
    final formatted = arrivalDepartureTime.formattedTimes(
      showOperationalTime: false,
      showTimesInBrackets: false,
      currentTime: DateTime(2026, 1, 1, 10, 40),
    );

    // THEN
    expect(formatted.$1, '(${Format.plannedTime(plannedReleasedTime)})');
    expect(formatted.$2, '(${Format.plannedTime(plannedArrival)})\n');
    expect(formatted.$3, isFalse);
    expect(formatted.$4, isFalse);
  });
}
