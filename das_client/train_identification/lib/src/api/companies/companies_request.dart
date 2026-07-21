import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:intl/intl.dart';
import 'package:train_identification/src/api/dto/train_identification_response_dto.dart';

class CompaniesRequest {
  const CompaniesRequest({
    required this.httpClient,
    required this.baseUrl,
  });

  final Client httpClient;
  final String baseUrl;

  Future<CompaniesResponse> call({
    required String operationalTrainNumber,
    required List<DateTime> startDates,
  }) async {
    final formattedStartDates = startDates.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();
    final queryParts = [
      for (final startDate in formattedStartDates) 'startDate=${Uri.encodeQueryComponent(startDate)}',
      'operationalTrainNumber=${Uri.encodeQueryComponent(operationalTrainNumber)}',
    ];
    final endpointUri = Uri.https(baseUrl, 'driver/v1/train-identifications/companies');
    final url = Uri.parse('$endpointUri?${queryParts.join('&')}');

    final response = await httpClient.get(url);

    return CompaniesResponse.fromHttpResponse(response);
  }
}

class CompaniesResponse {
  const CompaniesResponse({required this.headers, required this.body});

  factory CompaniesResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString);
      final dto = TrainIdentificationResponseDto.fromJson(json as Map<String, dynamic>);
      return CompaniesResponse(headers: response.headers, body: dto);
    }
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final TrainIdentificationResponseDto body;
}
