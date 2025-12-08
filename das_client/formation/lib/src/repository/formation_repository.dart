import 'package:formation/src/model/formation.dart';

abstract class FormationRepository {
  const FormationRepository._();

  Stream<Formation?> watchFormation({
    required String operationalTrainNumber,
    required String company,
    required DateTime operationalDay,
  });
}
