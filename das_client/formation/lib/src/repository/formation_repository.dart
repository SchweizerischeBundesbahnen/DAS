import 'package:formation/src/api/dto/formation_dto.dart';

abstract class FormationRepository {
  const FormationRepository._();

  Future<FormationDto?> loadFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
