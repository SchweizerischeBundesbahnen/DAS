import 'dart:convert';

import 'package:external_links/src/api/dto/external_links_response_dto.dart';
import 'package:http_x/component.dart';

class const ExternalLinksRequest({
  required final Client httpClient,
  required final String baseUrl,
  required final List<String> companies,
}) {
  Future<ExternalLinksResponse> call() async {
    final url = Uri.https(baseUrl, '/driver/v1/external-links', {'companies': companies.join(',')});

    final response = await httpClient.get(url);
    return ExternalLinksResponse.fromHttpResponse(response);
  }
}

class const ExternalLinksResponse({
  required final Map<String, String> headers,
  required final ExternalLinksResponseDto body,
}) {
  factory ExternalLinksResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final externalLinksDto = ExternalLinksResponseDto.fromJson(json);
      return ExternalLinksResponse(headers: response.headers, body: externalLinksDto);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }
}
