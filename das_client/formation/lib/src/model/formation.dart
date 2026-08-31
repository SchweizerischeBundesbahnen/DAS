import 'package:collection/collection.dart';
import 'package:formation/src/model/formation_run.dart';

class Formation({
  required final String operationalTrainNumber,
  required final String company,
  required final DateTime operationalDay,
  final List<FormationRun> formationRuns = const [],
}) {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formation &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          company == other.company &&
          operationalDay == other.operationalDay &&
          ListEquality().equals(formationRuns, other.formationRuns);

  @override
  int get hashCode => Object.hash(operationalTrainNumber, company, operationalDay, formationRuns);
}
