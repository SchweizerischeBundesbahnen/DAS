import 'package:user_properties/component.dart';

abstract class UserPropertiesRepository._() {
  Future<List<UserPropertyModel>> getAllUserProperties();

  Future<List<UserPropertyModel>> syncUserProperties();

  Future<UserPropertyModel?> getUserProperty(LocalKeyValueStoreKeys key);

  Future<UserPropertyModel> saveUserProperty(LocalKeyValueStoreKeys key, Object? value);

  Future<void> deleteUserProperty(LocalKeyValueStoreKeys key);

  Future<void> clearLocalUserProperties();

  void dispose();
}
