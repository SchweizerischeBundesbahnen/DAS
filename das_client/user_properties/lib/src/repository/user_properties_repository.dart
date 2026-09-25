import 'package:user_properties/src/api/model/user_property_model.dart';

abstract class UserPropertiesRepository._() {
  /*Future<bool> loadSettings();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode);

  Future<List<Company>> getCompanies();

  Future<Company?> getCompanyForCode(String companyCode);

  AppVersionExpiration? get appVersionExpiration;*/

  Future<List<UserPropertyModel>> getAllUserProperties();

  Future<UserPropertyModel?> getUserProperty(String key);

  Future<UserPropertyModel> saveUserProperty(String key, Object? value);

  Future<void> deleteUserProperty(String key);
}
