import 'package:user_properties/src/api/endpoint/user_properties.dart';

abstract class UserPropertiesApiService {
  UserPropertiesRequest userProperties();

  UserPropertyRequest userProperty(String key);

  SaveUserPropertyRequest saveUserProperty(String key, Object? value);

  DeleteUserPropertyRequest deleteUserProperty(String key);
}
