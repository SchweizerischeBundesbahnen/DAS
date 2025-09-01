import 'package:http_x/component.dart';
import 'package:settings/src/api/settings_api_service.dart';
import 'package:settings/src/api/settings_api_service_impl.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';
import 'package:settings/src/data/local/settings_database_service.dart';
import 'package:settings/src/repository/settings_config_repository.dart';
import 'package:settings/src/repository/settings_config_repository_impl.dart';

export 'package:settings/src/api/settings_api_service.dart';
export 'package:settings/src/data/local/ru_feature_database_service.dart';
export 'package:settings/src/model/ru_feature_keys.dart';
export 'package:settings/src/repository/settings_config_repository.dart';

class SettingsComponent {
  const SettingsComponent._();

  static SettingsApiService createApiService({
    required String baseUrl,
    required Client client,
  }) {
    return SettingsApiServiceImpl(baseUrl: baseUrl, httpClient: client);
  }

  static SettingsConfigRepository createRepository({required SettingsApiService apiService}) {
    return SettingsConfigRepositoryImpl(apiService: apiService, databaseService: databaseService());
  }

  static RuFeatureDatabaseService databaseService() {
    return SettingsDatabaseService.instance;
  }
}
