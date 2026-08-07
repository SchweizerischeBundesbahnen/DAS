import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:settings/component.dart';
import 'package:settings/src/api/dto/app_version_expiration_dto.dart';
import 'package:settings/src/api/dto/company_dto.dart';
import 'package:settings/src/api/dto/settings_dto.dart';
import 'package:settings/src/api/settings_api_service.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';

final _log = Logger('SettingsRepositoryImpl');

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.apiService,
    required this.databaseService,
    this._onAwsCredentialsChanged,
    this._onSettingsLoaded,
  }) {
    _init();
  }

  static const retryDelay = Duration(minutes: 1);

  final SettingsApiService apiService;
  final RuFeatureDatabaseService databaseService;
  final AwsCredentialsChanged? _onAwsCredentialsChanged;
  final SettingsLoaded? _onSettingsLoaded;

  SettingsDto? _lastSettings;

  void _init() async {
    final success = await loadSettings();
    if (!success) {
      Future.delayed(retryDelay).then((_) => _init());
    }
  }

  @override
  String? get loggingToken => _lastSettings?.logging.token;

  @override
  String? get loggingUrl => _lastSettings?.logging.url;

  @override
  AppVersionExpiration? get appVersionExpiration => _lastSettings?.currentAppVersion.toDomain();

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode) async {
    final ruFeature = await databaseService.findRuFeature(companyCode, featureKey);
    return ruFeature?.enabled ?? false;
  }

  @override
  Future<List<Company>> loadCompanies() async {
    final companies = await databaseService.findAllCompanies();
    return companies.map((company) => company.toDomain()).toList();
  }

  @override
  Future<Company?> getCompanyForCode(String companyCode) async {
    final company = await databaseService.findCompany(companyCode);
    return company?.toDomain();
  }

  @override
  Future<bool> loadSettings() async {
    SettingsDto? remoteSettings;
    try {
      remoteSettings = await _tryFetchSettings();
      if (remoteSettings == null) {
        _log.warning('Received empty settings.');
        return _reportResult(false);
      }
      _log.info('Settings fetched successfully.');
    } catch (e) {
      _log.warning('Connection error while loading settings.', e);
      return _reportResult(false);
    }

    await _replaceAllRuFeatureSettings(remoteSettings);
    await _saveCompanies(remoteSettings);

    if (_shouldCallAwsCredentialsChanged(remoteSettings)) {
      final preload = remoteSettings.preload;
      final config = remoteSettings.currentAppVersion.toDomain().isExpired
          ? null
          : AwsConfiguration(
              bucketUrl: preload.bucketUrl,
              accessKey: preload.accessKey,
              accessSecret: preload.accessSecret,
            );

      _onAwsCredentialsChanged!(config);
    }

    _lastSettings = remoteSettings;
    return _reportResult(true);
  }

  bool _reportResult(bool success) {
    _onSettingsLoaded?.call(success);
    return success;
  }

  Future<SettingsDto?> _tryFetchSettings() async {
    final settingsResponse = await apiService.settings();
    return settingsResponse.body.data.firstOrNull;
  }

  Future<void> _replaceAllRuFeatureSettings(SettingsDto remoteSettings) async {
    await databaseService.replaceAllRuFeatures(remoteSettings.ruFeatures);
    _log.info('RU settings saved successfully saved by replacing all.');
  }

  Future<void> _saveCompanies(SettingsDto remoteSettings) async {
    await databaseService.saveCompanies(remoteSettings.companies);
    _log.info('Companies saved successfully.');
  }

  bool _shouldCallAwsCredentialsChanged(SettingsDto remoteSettings) =>
      _onAwsCredentialsChanged != null &&
      (remoteSettings.preload != _lastSettings?.preload || remoteSettings.currentAppVersion.toDomain().expired);
}
