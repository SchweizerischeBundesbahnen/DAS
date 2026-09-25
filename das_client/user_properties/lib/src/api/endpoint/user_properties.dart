import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:user_properties/src/api/dto/user_properties_response_dto.dart';

class const UserPropertiesRequest({
  required final Client httpClient,
  required final String baseUrl,
  final Map<String, String>? headers,
}) {
  static const appVersionHeader = 'X-App-Version';

  Future<UserPropertiesResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/user_settings');
    final response = await httpClient.get(url, headers: headers);
    return UserPropertiesResponse.fromHttpResponse(response);
  }
}

class const UserPropertiesResponse({
  required final Map<String, String> headers,
  required final UserPropertiesResponseDto body,
}) {
  factory fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final userProperties = UserPropertiesResponseDto.fromJson(json);
      return UserPropertiesResponse(
        headers: response.headers,
        body: userProperties,
      );
    }
    // Failure
    throw HttpException.fromResponse(response);
  }
}
