import 'package:http_x/component.dart';
import 'package:settings/src/api/settings_api_service_impl.dart';
import 'package:settings/src/data/local/settings_database_service.dart';
import 'package:settings/src/repository/settings_config_repository.dart';
import 'package:settings/src/repository/settings_config_repository_impl.dart';

export 'package:settings/src/model/ru_feature_keys.dart';
export 'package:settings/src/repository/settings_config_repository.dart';

class SettingsComponent {
  const SettingsComponent._();

  static SettingsConfigRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return SettingsConfigRepositoryImpl(
      apiService: SettingsApiServiceImpl(baseUrl: baseUrl, httpClient: client),
      databaseService: SettingsDatabaseService.instance,
    );
  }
}
