import 'package:app/api/endpoint/settings.dart';
import 'package:http_x/component.dart';

class BackendApiService {
  BackendApiService({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  SettingsRequest get settings => SettingsRequest(httpClient: httpClient, baseUrl: baseUrl);
}
