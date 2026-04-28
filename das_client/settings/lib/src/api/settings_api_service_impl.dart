import 'package:http_x/component.dart';
import 'package:settings/src/api/endpoint/settings.dart';
import 'package:settings/src/api/settings_api_service.dart';

class SettingsApiServiceImpl implements SettingsApiService {
  SettingsApiServiceImpl({required this.baseUrl, required this.httpClient, required this.appVersion});

  final String baseUrl;
  final Client httpClient;
  final String appVersion;

  @override
  SettingsRequest get settings => SettingsRequest(
    httpClient: httpClient,
    baseUrl: baseUrl,
    headers: {SettingsRequest.appVersionHeader: appVersion},
  );
}
