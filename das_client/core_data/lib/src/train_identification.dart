import 'package:core_data/src/ru.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class TrainIdentification {
  TrainIdentification({
    required this.ru,
    required this.trainNumber,
    required DateTime date,
    this.operatingDay,
  }) : date = DateTime(date.year, date.month, date.day);

  final RailwayUndertaking ru;
  final String trainNumber;
  final DateTime date;
  final DateTime? operatingDay;

  int? get sanitizedTrainNumber {
    final firstNumberMatch = RegExp(r'\d+').firstMatch(trainNumber);
    if (firstNumberMatch == null) return null;
    return int.tryParse(firstNumberMatch.group(0)!);
  }

  @override
  String toString() {
    return 'TrainIdentification{ru: $ru, trainNumber: $trainNumber, date: $date, operatingDay: $operatingDay}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainIdentification &&
          runtimeType == other.runtimeType &&
          ru == other.ru &&
          trainNumber == other.trainNumber &&
          date == other.date &&
          operatingDay == other.operatingDay;

  @override
  int get hashCode => Object.hash(ru, trainNumber, date, operatingDay);
}
