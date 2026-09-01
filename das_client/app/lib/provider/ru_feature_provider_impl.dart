import 'package:app/provider/ru_feature_provider.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

class RuFeatureProviderImpl({
  required final SferaRepository _sferaRepo,
  required final SettingsRepository _settingsRepository,
}) implements RuFeatureProvider {
  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey) async {
    final activeTrain = _sferaRepo.connectedTrain;
    if (activeTrain == null) return false;

    return await _settingsRepository.isRuFeatureEnabled(featureKey, activeTrain.companyCode);
  }
}
