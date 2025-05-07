import 'package:meta/meta.dart';

@sealed
@immutable
class OtnId {
  const OtnId({
    required this.company,
    required this.operationalTrainNumber,
    required this.startDate,
    this.additionalTrainNumber,
  });

  final String company;
  final String operationalTrainNumber;
  final DateTime startDate;
  final String? additionalTrainNumber;
}
