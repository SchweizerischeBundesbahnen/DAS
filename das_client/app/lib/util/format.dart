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
  
  static String plannedTime(DateTime? date) => _formatLocal(date, DateFormat.HOUR24_MINUTE);

  static String operationalTime(DateTime? date) {
    final result = _formatLocal(date, DateFormat.HOUR24_MINUTE_SECOND);
    return result.isNotEmpty ? result.substring(0, 7) : result;
  }

  static String _formatLocal(DateTime? date, String formatPattern) {
    if (date == null) return '';
    return DateFormat(formatPattern).format(date.toLocal());
  }
}
