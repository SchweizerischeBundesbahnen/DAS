import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/model/ru_feature_keys.dart';

abstract class RuFeatureDatabaseService {
  const RuFeatureDatabaseService._();

  Future<void> saveRuFeatures(List<RuFeatureDto> ruFeatures);

  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey);
}
