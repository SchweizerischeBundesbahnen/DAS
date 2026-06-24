import 'dart:convert';
import 'dart:io';

import 'package:http_x/component.dart';
import 'package:ru_indications/src/api/dto/ru_indication_matches_response_dto.dart';
import 'package:ru_indications/src/api/matches/matches_request_body.dart';

class MatchesRequest {
  const MatchesRequest({
    required this.httpClient,
    required this.baseUrl,
  });

  final Client httpClient;
  final String baseUrl;

  Future<MatchesResponse> call({
    required String company,
    required int operationalTrainNumber,
    required DateTime startDate,
    required List<String> tafTapLocationReferences,
  }) async {
    final url = Uri.https(baseUrl, 'v1/ruindications/matches');
    final requestBody = MatchesRequestBody(
      company: company,
      operationalTrainNumber: operationalTrainNumber,
      startDate: startDate,
      tafTapLocationReferences: tafTapLocationReferences,
    );

    final response = await httpClient.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody.toJsonString(),
    );

    return MatchesResponse.fromHttpResponse(response);
  }
}

class MatchesResponse {
  const MatchesResponse({required this.headers, required this.body});

  factory MatchesResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString);
      final dto = RuIndicationMatchesResponseDto.fromJson(json as Map<String, dynamic>);
      return MatchesResponse(headers: response.headers, body: dto);
    }
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final RuIndicationMatchesResponseDto body;
}
