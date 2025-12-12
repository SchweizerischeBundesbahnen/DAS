import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/model/formation.dart';

abstract class FormationDatabaseService {
  const FormationDatabaseService._();

  Future<void> saveFormation(FormationDto formation, {String? etag});

  Future<String?> findFormationEtag(String operationalTrainNumber, String company, DateTime operationalDay);

  Future<Formation?> findFormation(String operationalTrainNumber, String company, DateTime operationalDay);

  Stream<Formation?> watchFormation(String operationalTrainNumber, String company, DateTime operationalDay);
}
