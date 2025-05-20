import 'dart:ui';

import 'package:intl/intl.dart';

class Format {
  const Format._();

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
}
