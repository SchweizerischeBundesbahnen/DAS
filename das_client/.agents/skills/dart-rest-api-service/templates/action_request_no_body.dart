import 'package:http_x/component.dart';

/// Use this template when the request has no body and uses only path parameters.
class ActionRequest {
  const ActionRequest({required this.httpClient, required this.baseUrl});

  final Client httpClient;
  final String baseUrl;

  Future<ActionResponse> call({
    required String pathParam1,
    required String pathParam2,
  }) async {
    final url = Uri.https(baseUrl, 'v1/<feature>/<action>/$pathParam1/$pathParam2');
    final response = await httpClient.post(url);

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

