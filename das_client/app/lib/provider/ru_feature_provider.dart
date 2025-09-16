import 'package:settings/component.dart';

abstract class RuFeatureProvider {
  const RuFeatureProvider._();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey);
}
