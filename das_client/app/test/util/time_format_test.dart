import 'package:app/util/time_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  late DateTime someDate;

  setUpAll(() {
    initializeDateFormatting();
  });

  setUp(() {
    someDate = DateTime(2025, 10, 1, 12, 30, 45);
  });

  test('plannedTime_whenCalledWithNull_thenReturnsEmptyString', () {
    // WHEN & THEN
    expect(TimeFormat.plannedTime(null), '');
  });

  test('plannedTime_whenCalledWithDate_thenReturnsPlannedTime', () {
    // WHEN & THEN
    expect(TimeFormat.plannedTime(someDate), _localHHMM(someDate));
  });

  test('operationalTime_whenCalledWithNull_thenReturnsEmptyString', () {
    // WHEN & THEN
    expect(TimeFormat.operationalTime(null), '');
  });

  test('operationalTime_whenCalledWithDate_thenReturnsOperationalTime', () {
    // WHEN & THEN
    expect(TimeFormat.operationalTime(someDate), _localHHMMSS(someDate).substring(0, 7));
  });
}

String _localHHMM(DateTime date) => DateFormat(DateFormat.HOUR24_MINUTE).format(date.toLocal());

String _localHHMMSS(DateTime date) => DateFormat(DateFormat.HOUR24_MINUTE_SECOND).format(date.toLocal());
