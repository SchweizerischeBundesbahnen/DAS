import 'dart:convert';
import 'dart:io';

import 'package:http_x/component.dart';
import 'package:user_properties/src/api/dto/user_properties_response_dto.dart';

class const UserPropertiesRequest({
  required final Client httpClient,
  required final String baseUrl,
  final Map<String, String>? headers,
}) {
  static const appVersionHeader = 'X-App-Version';

  Future<UserPropertiesResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/user-properties');
    final response = await httpClient.get(url, headers: headers);
    return UserPropertiesResponse.fromHttpResponse(response);
  }
}

class const UserPropertyRequest({
  required final Client httpClient,
  required final String baseUrl,
  required final String key,
  final Map<String, String>? headers,
}) {
  Future<UserPropertiesResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/user-properties/$key');
    final response = await httpClient.get(url, headers: headers);
    return UserPropertiesResponse.fromHttpResponse(response);
  }
}

class const SaveUserPropertyRequest({
  required final Client httpClient,
  required final String baseUrl,
  required final String key,
  required final Object? value,
  final Map<String, String>? headers,
}) {
  Future<UserPropertiesResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/user-properties/$key');
    final response = await httpClient.put(
      url,
      headers: {
        ...?headers,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(value),
    );
    return UserPropertiesResponse.fromHttpResponse(response);
  }
}

class const DeleteUserPropertyRequest({
  required final Client httpClient,
  required final String baseUrl,
  required final String key,
  final Map<String, String>? headers,
}) {
  Future<DeleteUserPropertyResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/user-properties/$key');
    final response = await httpClient.delete(url, headers: headers);
    return DeleteUserPropertyResponse.fromHttpResponse(response);
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
      final json = jsonDecode(body) as Map<String, dynamic>;
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

class const DeleteUserPropertyResponse({required final Map<String, String> headers}) {
  factory fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return DeleteUserPropertyResponse(headers: response.headers);
    }
    throw HttpException.fromResponse(response);
  }
}
