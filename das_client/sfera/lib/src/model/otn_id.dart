import 'package:meta/meta.dart';

/// Operational Train Number Identifier
@sealed
@immutable
class const OtnId({
  required final String company,
  required final String operationalTrainNumber,
  required final DateTime startDate,
}) {
  @override
  String toString() {
    return 'OtnId{company: $company, operationalTrainNumber: $operationalTrainNumber, startDate: $startDate}';
  }
}
