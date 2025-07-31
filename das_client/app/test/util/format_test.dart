import 'dart:ui';

import 'package:app/util/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  late DateTime someDate;

  setUp(() {
    initializeDateFormatting();
    someDate = DateTime(2025, 10, 1, 12, 30, 45);
  });

  test('date_whenCalledWithDateTime_thenReturnsFormattedDate', () {
    // GIVEN
    final expectedDate = '01.10.2025';

    // WHEN
    final result = Format.date(someDate);

    // THEN
    expect(result, expectedDate);
  });

  test('dateWithAbbreviatedDay_whenCalledWithEnLocale_thenReturnsCorrectFormat', () {
    // GIVEN
    final locale = Locale('en');
    final expectedDate = 'Wed 01.10.2025';

    // WHEN
    final result = Format.dateWithAbbreviatedDay(someDate, locale);

    // THEN
    expect(result, expectedDate);
  });

  test('dateWithAbbreviatedDay_whenCalledWithDeLocale_thenReturnsCorrectFormat', () {
    // GIVEN
    final locale = Locale('de');
    final expectedDate = 'Mi. 01.10.2025';

    // WHEN
    final result = Format.dateWithAbbreviatedDay(someDate, locale);

    // THEN
    expect(result, expectedDate);
  });

  test('plannedTime_whenCalledWithNull_thenReturnsEmptyString', () {
    // WHEN & THEN
    expect(Format.plannedTime(null), '');
  });

  test('plannedTime_whenCalledWithDate_thenReturnsPlannedTime', () {
    // WHEN & THEN
    expect(Format.plannedTime(someDate), _localHHMM(someDate));
  });

  test('operationalTime_whenCalledWithNull_thenReturnsEmptyString', () {
    // WHEN & THEN
    expect(Format.operationalTime(null), '');
  });

  test('operationalTime_whenCalledWithDate_thenReturnsOperationalTime', () {
    // WHEN & THEN
    expect(Format.operationalTime(someDate), _localHHMMSS(someDate).substring(0, 7));
  });
}

String _localHHMM(DateTime date) => DateFormat(DateFormat.HOUR24_MINUTE).format(date.toLocal());

String _localHHMMSS(DateTime date) => DateFormat(DateFormat.HOUR24_MINUTE_SECOND).format(date.toLocal());
