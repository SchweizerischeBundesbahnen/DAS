import 'package:settings/src/api/dto/company_dto.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/model/ru_feature_keys.dart';

abstract class RuFeatureDatabaseService._() {
  Future<void> replaceAllRuFeatures(List<RuFeatureDto> ruFeatures);

  Future<void> replaceAllCompanies(List<CompanyDto> companies);

  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey);

  Future<List<CompanyDto>> findAllCompanies();

  Future<CompanyDto?> findCompany(String companyCode);
}
