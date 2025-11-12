import 'package:formation/src/model/formation.dart';

abstract class FormationRepository {
  const FormationRepository._();

  Future<Formation?> loadFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
