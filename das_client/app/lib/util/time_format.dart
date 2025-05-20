import 'package:intl/intl.dart';

class TimeFormat {
  const TimeFormat._();

  static String _formatLocal(DateTime? date, String formatPattern) {
    if (date == null) return '';
    return DateFormat(formatPattern).format(date.toLocal());
  }

  static String plannedTime(DateTime? date) => _formatLocal(date, DateFormat.HOUR24_MINUTE);

  static String operationalTime(DateTime? date) {
    final result = _formatLocal(date, DateFormat.HOUR24_MINUTE_SECOND);
    return result.isNotEmpty ? result.substring(0, 7) : result;
  }
}
