import 'package:intl/intl.dart';

class Format {
  const Format._();

  static String sferaDate(DateTime date) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat('yyyy-MM-dd');
    return dateFormat.format(localDate);
  }

  static String sferaTimestamp(DateTime date) {
    final localDate = date.toLocal();
    final dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss'Z'");
    return dateFormat.format(localDate);
  }
}
