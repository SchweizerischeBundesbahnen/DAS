import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:logging/logging.dart';
import 'package:settings/src/api/dto/settings_response_dto.dart';

final _log = Logger('SettingsRequest');

class SettingsRequest {
  static const appVersionHeader = 'X-App-Version';

  const SettingsRequest({required this.httpClient, required this.baseUrl, this.headers});

  final Client httpClient;
  final String baseUrl;
  final Map<String, String>? headers;

  Future<SettingsResponse> call() async {
    final url = Uri.https(baseUrl, 'v1/settings');
    final response = await httpClient.get(url, headers: headers);
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
      _log.info(json);
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
