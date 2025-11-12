import 'package:formation/src/api/dto/formation_dto.dart';

abstract class FormationDatabaseService {
  const FormationDatabaseService._();

  Future<void> saveFormation(FormationDto formation);

  Future<FormationDto?> findFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
