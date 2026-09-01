import 'package:http_x/component.dart';
import 'package:settings/src/api/endpoint/settings.dart';
import 'package:settings/src/api/settings_api_service.dart';

class SettingsApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
  required final String appVersion,
}) implements SettingsApiService {
  @override
  SettingsRequest get settings => SettingsRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    headers: {SettingsRequest.appVersionHeader: appVersion},
  );
}
