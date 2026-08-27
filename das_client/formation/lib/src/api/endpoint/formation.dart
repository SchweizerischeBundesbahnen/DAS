import 'dart:convert';
import 'dart:io';

import 'package:formation/src/api/dto/formation_response_dto.dart';
import 'package:http_x/component.dart';
import 'package:intl/intl.dart';

class const FormationRequest({
  required final Client httpClient,
  required final String baseUrl,
  required final String operationalTrainNumber,
  required final String company,
  required final DateTime operationalDay,
  final String? etag,
}) {
  Future<FormationResponse> call() async {
    final url = Uri.https(
      baseUrl,
      'driver/v1/formations',
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

class const FormationResponse({
  required final Map<String, String> headers,
  required final FormationResponseDto? body,
  final String? etag,
}) {
  factory fromHttpResponse(Response response) {
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
}
