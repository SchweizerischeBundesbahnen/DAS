import 'package:settings/component.dart';

abstract class const RuFeatureProvider._() {
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey);
}
