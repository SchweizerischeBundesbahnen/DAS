import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:intl/intl.dart';
import 'package:train_identification/src/api/dto/train_identification_response_dto.dart';

class const CompaniesRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<CompaniesResponse> call({
    required String operationalTrainNumber,
    required List<DateTime> startDates,
  }) async {
    final formattedStartDates = startDates.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();

    final url = Uri.https(baseUrl, 'driver/v1/train-identifications/companies', {
      'startDate': formattedStartDates,
      'operationalTrainNumber': operationalTrainNumber,
    });

    final response = await httpClient.get(url);

    return CompaniesResponse.fromHttpResponse(response);
  }
}

class CompaniesResponse({
  required final Map<String, String> headers,
  required final TrainIdentificationResponseDto body,
}) {
  factory fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString);
      final dto = TrainIdentificationResponseDto.fromJson(json as Map<String, dynamic>);
      return CompaniesResponse(headers: response.headers, body: dto);
    }
    throw HttpException.fromResponse(response);
  }
}
