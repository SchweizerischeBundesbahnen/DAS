import 'dart:io';

import 'package:<feature>/src/api/<action>/<action>_request_body.dart';
import 'package:http_x/component.dart';

class ActionRequest {
  const ActionRequest({
    required this.httpClient,
    required this.baseUrl,
  });

  final Client httpClient;
  final String baseUrl;

  Future<ActionResponse> call({
    required String param1,
    required String param2,
  }) async {
    final url = Uri.https(baseUrl, 'v1/<feature>/<action>');
    final requestBody = ActionRequestBody(
      param1: param1,
      param2: param2,
    );

    final response = await httpClient.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody.toJsonString(),
    );

    return ActionResponse.fromHttpResponse(response);
  }
}

class ActionResponse {
  const ActionResponse({required this.headers});

  factory ActionResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return ActionResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
}
