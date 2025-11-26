import 'package:formation/src/model/formation.dart';

abstract class FormationRepository {
  const FormationRepository._();

  Stream<Formation?> watchFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
