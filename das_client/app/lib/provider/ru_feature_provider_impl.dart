import 'package:app/provider/ru_feature_provider.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

class RuFeatureProviderImpl implements RuFeatureProvider {
  RuFeatureProviderImpl({
    required SferaRepo sferaRepo,
    required SettingsRepository settingsRepository,
  }) : _sferaRepo = sferaRepo,
       _settingsRepository = settingsRepository;

  final SferaRepo _sferaRepo;
  final SettingsRepository _settingsRepository;

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey) async {
    final activeTrain = _sferaRepo.connectedTrain;
    if (activeTrain == null) return false;

    return await _settingsRepository.isRuFeatureEnabled(featureKey, activeTrain.ru.companyCode);
  }
}
