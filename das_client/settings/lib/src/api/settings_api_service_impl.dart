import 'package:http_x/component.dart';
import 'package:settings/src/api/endpoint/settings.dart';
import 'package:settings/src/api/settings_api_service.dart';

class SettingsApiServiceImpl implements SettingsApiService {
  SettingsApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  SettingsRequest get settings => SettingsRequest(httpClient: httpClient, baseUrl: baseUrl);
}
