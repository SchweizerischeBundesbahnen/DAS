import 'package:http_x/component.dart';
import 'package:settings/src/api/settings_api_service_impl.dart';
import 'package:settings/src/data/local/settings_database_service.dart';
import 'package:settings/src/repository/settings_repository.dart';
import 'package:settings/src/repository/settings_repository_impl.dart';

export 'package:settings/src/model/ru_feature_keys.dart';
export 'package:settings/src/repository/settings_repository.dart';

class SettingsComponent {
  const SettingsComponent._();

  static SettingsRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return SettingsRepositoryImpl(
      apiService: SettingsApiServiceImpl(baseUrl: baseUrl, httpClient: client),
      databaseService: SettingsDatabaseService.instance,
    );
  }
}
