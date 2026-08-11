extension DateTimeExtension on DateTime {
  DateTime get roundDownToTenthOfSecond => copyWith(
    millisecond: (millisecond ~/ 100) * 100,
    microsecond: 0,
  );

  DateTime get roundDownToMinute => copyWith(
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
