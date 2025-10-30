import 'package:settings/component.dart';

abstract class RuFeatureProvider {
  // TODO: do not provide view model if feature disabled and add 'safe' context.read method
  const RuFeatureProvider._();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey);
}
