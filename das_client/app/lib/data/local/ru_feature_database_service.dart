import 'package:app/api/dto/ru_feature_dto.dart';
import 'package:app/model/ru_feature_keys.dart';

abstract class RuFeatureDatabaseService {
  const RuFeatureDatabaseService._();

  Future<void> saveRuFeatures(List<RuFeatureDto> ruFeatures);

  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey);
}
