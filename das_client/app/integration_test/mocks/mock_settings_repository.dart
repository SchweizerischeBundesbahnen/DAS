import 'package:settings/component.dart';

class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository() : _appVersionExpiration = AppVersionExpiration(expired: false);

  AppVersionExpiration? _appVersionExpiration;

  @override
  AppVersionExpiration? get appVersionExpiration => _appVersionExpiration;

  set appVersionExpiration(AppVersionExpiration? value) => _appVersionExpiration = value;

  @override
  Future<bool> loadSettings() async => true;

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode) async => true;

  @override
  String? get loggingUrl => '';

  @override
  String? get loggingToken => '';
}
