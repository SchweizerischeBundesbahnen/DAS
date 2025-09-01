import 'package:logging/logging.dart';
import 'package:settings/src/api/dto/logging_setting_dto.dart';
import 'package:settings/src/api/settings_api_service.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';
import 'package:settings/src/repository/settings_config_repository.dart';

final _log = Logger('DasConfigRepositoryImpl');

class SettingsConfigRepositoryImpl implements SettingsConfigRepository {
  SettingsConfigRepositoryImpl({required this.apiService, required this.databaseService}) {
    init();
  }

  final SettingsApiService apiService;
  final RuFeatureDatabaseService databaseService;

  LoggingSettingDto? _loggingSetting;

  void init() async {
    final success = await loadSettings();
    if (!success) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        init();
      });
    }
  }

  Future<bool> loadSettings() async {
    try {
      final settingsResponse = await apiService.settings();
      final settings = settingsResponse.body.data.firstOrNull;
      if (settings != null) {
        _loggingSetting = settings.logging;
        await databaseService.saveRuFeatures(settings.ruFeatures);
        _log.info('Settings loaded successfully.');
        return true;
      }
      _log.warning('Received empty settings');
    } catch (e) {
      _log.severe('Connection error while loading settings', e);
    }

    return false;
  }

  @override
  String? get token => _loggingSetting?.token;

  @override
  String? get url => _loggingSetting?.url;
}
