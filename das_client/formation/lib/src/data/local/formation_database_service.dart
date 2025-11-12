import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/model/formation.dart';

abstract class FormationDatabaseService {
  const FormationDatabaseService._();

  Future<void> saveFormation(FormationDto formation);

  Future<Formation?> findFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
