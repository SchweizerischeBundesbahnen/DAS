extension DateTimeExtension on DateTime {
  DateTime roundDownToMinute() => copyWith(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
}
