import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:formation/src/data/local/formation_database_service.dart';
import 'package:formation/src/repository/formation_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('FormationRepositoryImpl');

class FormationRepositoryImpl implements FormationRepository {
  FormationRepositoryImpl({required this.apiService, required this.databaseService});

  final FormationApiService apiService;
  final FormationDatabaseService databaseService;

  @override
  Future<FormationDto?> loadFormation(String operationalTrainNumber, String company, DateTime operationalDay) async {
    try {
      final formationResponse = await apiService.formation(operationalTrainNumber, company, operationalDay).call();
      final formation = formationResponse.body.data.firstOrNull;
      if (formation != null) {
        await databaseService.saveFormation(formation);
        _log.info('Formation loaded successfully.');
        return formation;
      }
      _log.warning('Received empty formation');
    } catch (e) {
      _log.severe('Connection error while loading formation', e);
    }

    return null;
  }
}
