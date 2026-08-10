import 'package:core_data/component.dart';
import 'package:logger/component.dart';
import 'package:settings/component.dart';

abstract class SettingsRepository implements LogEndpoint {
  const SettingsRepository._();

  Future<bool> loadSettings();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode);

  Future<List<Company>> getCompanies();

  Future<Company?> getCompanyForCode(String companyCode);

  AppVersionExpiration? get appVersionExpiration;
}
