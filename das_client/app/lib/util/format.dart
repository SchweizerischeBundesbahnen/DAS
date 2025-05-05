import 'dart:ui';

import 'package:intl/intl.dart';

class Format {
  const Format._();

  static String dateTime(DateTime date, {bool showSeconds = false}) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat.yMMMd();
    showSeconds ? dateFormat.add_Hms() : dateFormat.add_Hm();
    return dateFormat.format(localDate);
  }

  static String date(DateTime date) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat('dd.MM.yyyy');
    return dateFormat.format(localDate);
  }

  static String dateWithAbbreviatedDay(DateTime date, Locale locale) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat('E dd.MM.yyyy', locale.toLanguageTag());
    return dateFormat.format(localDate);
  }

  static String time(DateTime date, {bool showSeconds = true}) {
    final localDate = date.toLocal();
    final format = showSeconds ? DateFormat.HOUR24_MINUTE_SECOND : DateFormat.HOUR24_MINUTE;
    return DateFormat(format).format(localDate);
  }
}
