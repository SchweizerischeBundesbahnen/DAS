import 'package:formation/src/model/formation_run.dart';

class Formation {
  Formation({
    required this.operationalTrainNumber,
    required this.company,
    required this.operationalDay,
    this.formationRuns = const [],
  });

  final String operationalTrainNumber;
  final String company;
  final DateTime operationalDay;
  final List<FormationRun> formationRuns;
}
