import 'package:app/model/ru.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class TrainIdentification {
  const TrainIdentification({
    required this.ru,
    required this.trainNumber,
    required this.date,
  });

  final Ru ru;
  final String trainNumber;
  final DateTime date;
}
