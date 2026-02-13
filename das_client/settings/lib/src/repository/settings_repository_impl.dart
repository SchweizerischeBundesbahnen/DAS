import 'package:logging/logging.dart';
import 'package:settings/component.dart';
import 'package:settings/src/api/dto/logging_setting_dto.dart';
import 'package:settings/src/api/settings_api_service.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';

final _log = Logger('SettingsRepositoryImpl');

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.apiService,
    required this.databaseService,
    this.onAwsCredentialsChanged,
  }) {
    init();
  }

  static const retryDelay = Duration(minutes: 1);

  final SettingsApiService apiService;
  final RuFeatureDatabaseService databaseService;
  final AwsCredentialsChanged? onAwsCredentialsChanged;

  LoggingSettingDto? _loggingSetting;

  void init() async {
    final success = await loadSettings();
    if (!success) {
      Future.delayed(retryDelay).then((_) => init());
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

        if (onAwsCredentialsChanged != null) {
          final preload = settings.preload;
          onAwsCredentialsChanged!(
            AwsConfiguration(
              bucketUrl: preload.bucketUrl,
              accessKey: preload.accessKey,
              accessSecret: preload.accessSecret,
            ),
          );
        }

        return true;
      }
      _log.warning('Received empty settings');
    } catch (e) {
      _log.severe('Connection error while loading settings', e);
    }

    return false;
  }

  @override
  String? get loggingToken => _loggingSetting?.token;

  @override
  String? get loggingUrl => _loggingSetting?.url;

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode) async {
    final ruFeature = await databaseService.findRuFeature(companyCode, featureKey);
    return ruFeature?.enabled ?? false;
  }
}
