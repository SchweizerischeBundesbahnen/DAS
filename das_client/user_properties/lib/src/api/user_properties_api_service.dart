import 'package:user_properties/src/api/dto/user_property_value_dto.dart';
import 'package:user_properties/src/api/endpoint/user_properties.dart';

abstract class UserPropertiesApiService {
  UserPropertiesRequest userProperties();

  UserPropertyRequest userProperty(String key);

  SaveUserPropertyRequest saveUserProperty(String key, UserPropertyValueDto value);
}
