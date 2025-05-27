import 'package:meta/meta.dart';

@sealed
@immutable
class OtnId {
  /// Operational Train Number Identifier
  const OtnId({
    required this.company,
    required this.operationalTrainNumber,
    required this.startDate,
  });

  final String company;
  final String operationalTrainNumber;
  final DateTime startDate;
}
