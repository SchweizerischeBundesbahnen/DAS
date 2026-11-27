import 'package:http_x/component.dart';
import 'package:user_properties/src/api/user_properties_api_service_impl.dart';
import 'package:user_properties/src/provider/user_id_provider_properties.dart';
import 'package:user_properties/src/repository/user_properties_repository.dart';
import 'package:user_properties/src/repository/user_properties_repository_impl.dart';

export 'package:user_properties/src/api/model/user_property_model.dart';
export 'package:user_properties/src/provider/user_id_provider_properties.dart';
export 'package:user_properties/src/repository/local_key_value_store.dart';
export 'package:user_properties/src/repository/user_properties_repository.dart';

class UserPropertiesComponent._() {
  static UserPropertiesRepository createRepository({
    required String baseUrl,
    required Client client,
    required String appVersion,
    required UserIdProviderProperties userIdProvider,
  }) {
    return UserPropertiesRepositoryImpl(
      apiService: UserPropertiesApiServiceImpl(
        baseUrl: baseUrl,
        httpClient: client,
        appVersion: appVersion,
      ),
      userIdProvider: userIdProvider,
    );
  }
}
