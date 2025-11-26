import 'dart:convert';

import 'package:formation/src/api/dto/formation_response_dto.dart';
import 'package:http_x/component.dart';
import 'package:intl/intl.dart';

class FormationRequest {
  const FormationRequest({
    required this.httpClient,
    required this.baseUrl,
    required this.operationalTrainNumber,
    required this.company,
    required this.operationalDay,
  });

  final Client httpClient;
  final String baseUrl;
  final String operationalTrainNumber;
  final String company;
  final DateTime operationalDay;

  Future<FormationResponse> call() async {
    final url = Uri.https(
      baseUrl,
      'v1/formations',
      {
        'operationalTrainNumber': operationalTrainNumber,
        'company': company,
        'operationalDay': DateFormat('yyyy-MM-dd').format(operationalDay),
      },
    );
    final response = await httpClient.get(url);
    return FormationResponse.fromHttpResponse(response);
  }
}

class FormationResponse {
  const FormationResponse({required this.headers, required this.body});

  factory FormationResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status == 200;
    if (isSuccess) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final formation = FormationResponseDto.fromJson(json);
      return FormationResponse(
        headers: response.headers,
        body: formation,
      );
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final FormationResponseDto body;
}
