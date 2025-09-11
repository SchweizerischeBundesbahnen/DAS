import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:settings/src/api/dto/settings_response_dto.dart';

class SettingsRequest {
  const SettingsRequest({required this.httpClient, required this.baseUrl});

  final Client httpClient;
  final String baseUrl;

  Future<SettingsResponse> call() async {
    final url = Uri.https(baseUrl, 'v1/settings');
    final response = await httpClient.get(url);
    return SettingsResponse.fromHttpResponse(response);
  }
}

class SettingsResponse {
  const SettingsResponse({required this.headers, required this.body});

  factory SettingsResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status == 200;
    if (isSuccess) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      print(json);
      final settings = SettingsResponseDto.fromJson(json);
      return SettingsResponse(
        headers: response.headers,
        body: settings,
      );
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final SettingsResponseDto body;
}
