import 'package:http_x/component.dart';

class ConfirmRequest {
  const ConfirmRequest({required this.httpClient, required this.baseUrl});

  final Client httpClient;
  final String baseUrl;

  Future<ConfirmResponse> call({
    required String messageId,
    required String deviceId,
  }) async {
    final url = Uri.https(baseUrl, 'v1/customer-oriented-departure/confirm/$messageId/$deviceId');
    final response = await httpClient.get(url);

    return ConfirmResponse.fromHttpResponse(response);
  }
}

class ConfirmResponse {
  const ConfirmResponse({required this.headers});

  factory ConfirmResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return ConfirmResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
}
