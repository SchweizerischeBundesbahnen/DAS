import 'package:logger/component.dart';
import 'package:settings/component.dart';
import 'package:settings/src/model/app_version_expiration.dart';

abstract class SettingsRepository implements LogEndpoint {
  const SettingsRepository._();

  Future<bool> loadSettings();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode);

  AppVersionExpiration? get appVersionExpiration;
}
