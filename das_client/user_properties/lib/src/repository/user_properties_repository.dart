import 'package:user_properties/component.dart';

abstract class UserPropertiesRepository._() {
  /*Future<bool> loadSettings();

  Future<bool> isRuFeatureEnabled(RuFeatureKeys featureKey, String companyCode);

  Future<List<Company>> getCompanies();

  Future<Company?> getCompanyForCode(String companyCode);

  AppVersionExpiration? get appVersionExpiration;*/

  Future<List<UserPropertyModel>> get getAllUserProperties;

  Future<UserPropertyModel> get getUserProperty;

  Future<void> saveUserProperty();

  Future<void> deleteUserProperty();
}
