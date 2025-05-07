import 'package:meta/meta.dart';
import 'package:sfera/src/model/ru.dart';

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
