import 'package:intl/intl.dart';

class Format {
  const Format._();

  static String dateTime(DateTime date, {bool showSeconds = false}) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat.yMMMd();
    showSeconds ? dateFormat.add_Hms() : dateFormat.add_Hm();
    return dateFormat.format(localDate);
  }

  static String time(DateTime date, {bool showSeconds = true}) {
    final localDate = date.toLocal();
    final format = showSeconds ? DateFormat.HOUR24_MINUTE_SECOND : DateFormat.HOUR24_MINUTE;
    return DateFormat(format).format(localDate);
  }

  static String meters(double value, {int decimalDigits = 2}) {
    final numberFormat = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    final number = numberFormat.format(value);
    return '$number m';
  }
}