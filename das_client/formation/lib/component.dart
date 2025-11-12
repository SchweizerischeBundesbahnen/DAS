import 'package:formation/src/api/formation_api_service_impl.dart';
import 'package:formation/src/data/local/formation_database_service_impl.dart';
import 'package:formation/src/repository/formation_repository.dart';
import 'package:formation/src/repository/formation_repository_impl.dart';
import 'package:http_x/component.dart';

export 'package:formation/src/model/formation.dart';
export 'package:formation/src/model/formation_run.dart';
export 'package:formation/src/repository/formation_repository.dart';

class FormationComponent {
  const FormationComponent._();

  static FormationRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return FormationRepositoryImpl(
      apiService: FormationApiServiceImpl(baseUrl: baseUrl, httpClient: client),
      databaseService: FormationDatabaseServiceImpl.instance,
    );
  }
}
