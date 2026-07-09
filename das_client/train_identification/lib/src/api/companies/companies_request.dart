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
    required DateTime startDate,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
    final url = Uri.https(baseUrl, 'driver/v1/trainidentifications/companies', {
      'operationalTrainNumber': operationalTrainNumber,
      'startDate': formattedDate,
    });

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
