import 'package:meta/meta.dart';

@sealed
@immutable
class TrainIdentification {
  TrainIdentification({
    required this.companyCode,
    required this.trainNumber,
    required DateTime date,
    this.operatingDay,
  }) : date = DateTime(date.year, date.month, date.day);

  final String companyCode;
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
    return 'TrainIdentification{companyCode: $companyCode, trainNumber: $trainNumber, date: $date, operatingDay: $operatingDay}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainIdentification &&
          runtimeType == other.runtimeType &&
          companyCode == other.companyCode &&
          trainNumber == other.trainNumber &&
          date == other.date &&
          operatingDay == other.operatingDay;

  @override
  int get hashCode => Object.hash(companyCode, trainNumber, date, operatingDay);
}
