import 'package:formation/src/model/formation.dart';

abstract class FormationRepository {
  const FormationRepository._();

  Future<Formation?> reloadFormation(String operationalTrainNumber, String company, DateTime operationalDay);

  Stream<Formation?> watchFormation({
    required String operationalTrainNumber,
    required String company,
    required DateTime operationalDay,
  });
}
