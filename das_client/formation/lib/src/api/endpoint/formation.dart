import 'dart:convert';
import 'dart:io';

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
    this.etag,
  });

  final Client httpClient;
  final String baseUrl;
  final String operationalTrainNumber;
  final String company;
  final DateTime operationalDay;
  final String? etag;

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
    final headers = <String, String>{};
    if (etag != null) {
      headers['If-None-Match'] = etag!;
    }

    final response = await httpClient.get(url, headers: headers);
    return FormationResponse.fromHttpResponse(response);
  }
}

class FormationResponse {
  const FormationResponse({required this.headers, required this.body, this.etag});

  factory FormationResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status == HttpStatus.notFound || status == HttpStatus.notModified) {
      return FormationResponse(headers: response.headers, body: null, etag: response.headers['etag']);
    } else if (status == HttpStatus.ok) {
      final body = utf8.decode(response.bodyBytes);
      final json = jsonDecode(body);
      final formation = FormationResponseDto.fromJson(json);
      return FormationResponse(
        headers: response.headers,
        body: formation,
        etag: response.headers['etag'],
      );
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final FormationResponseDto? body;
  final String? etag;
}
