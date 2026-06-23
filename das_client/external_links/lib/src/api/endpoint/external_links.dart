import 'dart:convert';

import 'package:external_links/src/api/dto/external_links_response_dto.dart';
import 'package:http_x/component.dart';

class ExternalLinksRequest {
  const ExternalLinksRequest({required this.httpClient, required this.baseUrl, required this.companies});

  final Client httpClient;
  final String baseUrl;
  final List<String> companies;

  Future<ExternalLinksResponse> call() async {
    final url = Uri.https(baseUrl, '/v1/mobile/external-links', {'companies': companies.join(',')});

    final response = await httpClient.get(url);
    return ExternalLinksResponse.fromHttpResponse(response);
  }
}

class ExternalLinksResponse {
  const ExternalLinksResponse({required this.headers, required this.body});

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

  final Map<String, String> headers;
  final ExternalLinksResponseDto body;
}
