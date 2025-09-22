import 'package:logger/component.dart';
import 'package:settings/component.dart';

abstract class SettingsRepository implements LogEndpoint {
  const SettingsRepository._();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode);
}
