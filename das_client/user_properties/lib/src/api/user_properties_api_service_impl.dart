import 'package:user_properties/src/api/dto/user_property_value_dto.dart';
import 'package:user_properties/src/api/endpoint/user_properties.dart';
import 'package:http_x/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';

class UserPropertiesApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
  required final String appVersion,
}) implements UserPropertiesApiService {
  @override
  UserPropertiesRequest userProperties() => UserPropertiesRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    headers: {UserPropertiesRequest.appVersionHeader: appVersion},
  );

  @override
  UserPropertyRequest userProperty(String key) => UserPropertyRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    key: key,
    headers: {UserPropertiesRequest.appVersionHeader: appVersion},
  );

  @override
  SaveUserPropertyRequest saveUserProperty(String key, UserPropertyValueDto value) => SaveUserPropertyRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    key: key,
    value: value,
    headers: {UserPropertiesRequest.appVersionHeader: appVersion},
  );
}
