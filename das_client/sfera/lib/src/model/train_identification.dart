import 'package:meta/meta.dart';
import 'package:sfera/src/data/mapper/datetime_x.dart';
import 'package:sfera/src/model/ru.dart';

@sealed
@immutable
class TrainIdentification {
  const TrainIdentification({
    required this.ru,
    required this.trainNumber,
    required this.date,
  });

  final RailwayUndertaking ru;
  final String trainNumber;
  final DateTime date;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    other as TrainIdentification;
    return ru == other.ru && trainNumber == other.trainNumber && date.isSameDay(other.date);
  }

  @override
  int get hashCode => Object.hash(ru, trainNumber, date);

  @override
  String toString() {
    return 'TrainIdentification{ru: $ru, trainNumber: $trainNumber, date: $date}';
  }
}
