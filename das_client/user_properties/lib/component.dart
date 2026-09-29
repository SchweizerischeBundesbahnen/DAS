import 'package:http_x/component.dart';
import 'package:user_properties/src/api/user_properties_api_service_impl.dart';
import 'package:user_properties/src/repository/local_key_value_store.dart';
import 'package:user_properties/src/repository/user_properties_repository.dart';
import 'package:user_properties/src/repository/user_properties_repository_impl.dart';

export 'package:user_properties/src/repository/local_key_value_store.dart';
export 'package:user_properties/src/repository/user_properties_repository.dart';
export 'package:user_properties/src/api/model/user_property_model.dart';
export 'package:user_properties/src/provider/user_id_provider.dart';

class UserPropertiesComponent._() {
  static UserPropertiesRepository createRepository({
    required String baseUrl,
    required Client client,
    required LocalKeyValueStore localStore,
    required String appVersion,
  }) {
    return UserPropertiesRepositoryImpl(
      apiService: UserPropertiesApiServiceImpl(
        baseUrl: baseUrl,
        httpClient: client,
        appVersion: appVersion,
      ),
      localStore: localStore,
    );
  }
}
