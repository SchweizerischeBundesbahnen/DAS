extension DateTimeX on DateTime {
  static DateTime? parseNullable(String? formattedString) {
    if (formattedString == null) return null;
    return DateTime.parse(formattedString);
  }

  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  DateTime floorToDay() => DateTime(year, month, day);
}
