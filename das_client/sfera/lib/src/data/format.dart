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

  /// Returns formatted sfera train. Example: 1513_2025-10-10
  static String sferaTrain(String trainNumber, DateTime date) => '${trainNumber}_${Format.sferaDate(date)}';
}
