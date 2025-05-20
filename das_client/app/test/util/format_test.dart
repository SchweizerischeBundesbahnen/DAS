import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:app/util/format.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting();
  });

  test('date_whenCalledWithDateTime_thenReturnsFormattedDate', () {
    // GIVEN
    final date = DateTime(2023, 10, 10);
    final expectedDate = '10.10.2023';

    // WHEN
    final result = Format.date(date);

    // THEN
    expect(result, expectedDate);
  });

  test('dateWithAbbreviatedDay_whenCalledWithEnLocale_thenReturnsCorrectFormat', () {
    // GIVEN
    final date = DateTime(2023, 10, 10);
    final locale = Locale('en');
    final expectedDate = 'Tue 10.10.2023';

    // WHEN
    final result = Format.dateWithAbbreviatedDay(date, locale);

    // THEN
    expect(result, expectedDate);
  });

  test('dateWithAbbreviatedDay_whenCalledWithDeLocale_thenReturnsCorrectFormat', () {
    // GIVEN
    final date = DateTime(2023, 10, 10);
    final locale = Locale('de');
    final expectedDate = 'Di. 10.10.2023';

    // WHEN
    final result = Format.dateWithAbbreviatedDay(date, locale);

    // THEN
    expect(result, expectedDate);
  });
}
