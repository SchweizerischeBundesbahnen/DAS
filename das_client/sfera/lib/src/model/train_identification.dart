import 'package:meta/meta.dart';
import 'package:sfera/src/model/ru.dart';

@sealed
@immutable
class TrainIdentification {
  const TrainIdentification({
    required this.ru,
    required this.trainNumber,
    required this.date,
    this.operatingDay,
  });

  final RailwayUndertaking ru;
  final String trainNumber;
  final DateTime date;
  final DateTime? operatingDay;

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
