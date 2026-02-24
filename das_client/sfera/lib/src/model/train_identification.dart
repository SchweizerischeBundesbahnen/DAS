import 'package:meta/meta.dart';
import 'package:sfera/src/model/ru.dart';

@sealed
@immutable
class TrainIdentification {
  TrainIdentification({
    required this.ru,
    required this.trainNumber,
    required DateTime date,
    this.operatingDay,
    this.tafTapLocationReferenceStart,
    this.tafTapLocationReferenceEnd,
  }) : date = DateTime(date.year, date.month, date.day);

  final RailwayUndertaking ru;
  final String trainNumber;
  final DateTime date;
  final DateTime? operatingDay;
  final String? tafTapLocationReferenceStart;
  final String? tafTapLocationReferenceEnd;

  @override
  String toString() {
    return 'TrainIdentification{ru: $ru, trainNumber: $trainNumber, date: $date, operatingDay: $operatingDay, tafTapLocationReferenceStart: $tafTapLocationReferenceStart, tafTapLocationReferenceEnd: $tafTapLocationReferenceEnd}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainIdentification &&
          runtimeType == other.runtimeType &&
          ru == other.ru &&
          trainNumber == other.trainNumber &&
          date == other.date &&
          operatingDay == other.operatingDay &&
          tafTapLocationReferenceStart == other.tafTapLocationReferenceStart &&
          tafTapLocationReferenceEnd == other.tafTapLocationReferenceEnd;

  @override
  int get hashCode =>
      Object.hash(ru, trainNumber, date, operatingDay, tafTapLocationReferenceStart, tafTapLocationReferenceEnd);
}
