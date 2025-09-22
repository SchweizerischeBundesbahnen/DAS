import 'package:app/provider/ru_feature_provider.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

class RuFeatureProviderImpl implements RuFeatureProvider {
  RuFeatureProviderImpl({
    required SferaRemoteRepo sferaRemoteRepo,
    required SettingsRepository settingsRepository,
  }) : _sferaRemoteRepo = sferaRemoteRepo,
       _settingsRepository = settingsRepository;

  final SferaRemoteRepo _sferaRemoteRepo;
  final SettingsRepository _settingsRepository;

  @override
  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey) async {
    final activeTrain = _sferaRemoteRepo.connectedTrain;
    if (activeTrain == null) return false;

    return await _settingsRepository.isRuFeatureEnabled(featureKey, activeTrain.ru.companyCode);
  }
}
