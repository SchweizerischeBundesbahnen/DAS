import 'package:app/provider/ru_feature_provider.dart';
import 'package:settings/src/model/ru_feature_keys.dart';

class MockRuFeatureProvider implements RuFeatureProvider {
  MockRuFeatureProvider() {
    for (final it in RuFeatureKeys.values) {
      _featureFlags[it] = true;
    }
  }

  final Map<RuFeatureKeys, bool> _featureFlags = {};

  void enableFeature(RuFeatureKeys featureKey) {
    _featureFlags[featureKey] = true;
  }

  void disableFeature(RuFeatureKeys featureKey) {
    _featureFlags[featureKey] = false;
  }

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey) {
    return _featureFlags[featureKey] == true ? Future.value(true) : Future.value(false);
  }
}
