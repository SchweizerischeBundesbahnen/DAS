extension DateTimeX on DateTime {
  static DateTime? parseNullable(String? formattedString) {
    if (formattedString == null) return null;
    return DateTime.parse(formattedString);
  }
}
