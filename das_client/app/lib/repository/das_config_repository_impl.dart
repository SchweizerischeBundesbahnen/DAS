import 'package:app/api/backend_api_service.dart';
import 'package:app/api/dto/logging_setting_dto.dart';
import 'package:app/data/local/das_database_service.dart';
import 'package:app/repository/das_config_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('DasConfigRepositoryImpl');

class DasConfigRepositoryImpl implements DasConfigRepository {
  DasConfigRepositoryImpl({required this.apiService, required this.databaseService}) {
    init();
  }

  final BackendApiService apiService;
  final DASDatabaseService databaseService;

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
