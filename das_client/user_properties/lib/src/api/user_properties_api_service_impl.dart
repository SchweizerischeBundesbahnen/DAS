import 'package:user_properties/src/api/endpoint/user_properties.dart';
import 'package:http_x/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';

class UserPropertiesApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
  required final String appVersion,
}) implements UserPropertiesApiService {
  @override
  UserPropertiesRequest get userProperties => UserPropertiesRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    headers: {UserPropertiesRequest.appVersionHeader: appVersion},
  );
}
