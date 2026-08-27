import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:settings/src/api/dto/settings_response_dto.dart';

class const SettingsRequest({
  required final Client httpClient,
  required final String baseUrl,
  final Map<String, String>? headers,
}) {
  static const appVersionHeader = 'X-App-Version';

  Future<SettingsResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/settings');
    final response = await httpClient.get(url, headers: headers);
    return SettingsResponse.fromHttpResponse(response);
  }
}

class const SettingsResponse({
  required final Map<String, String> headers,
  required final SettingsResponseDto body,
}) {
  factory SettingsResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final settings = SettingsResponseDto.fromJson(json);
      return SettingsResponse(
        headers: response.headers,
        body: settings,
      );
    }
    // Failure
    throw HttpException.fromResponse(response);
  }
}
