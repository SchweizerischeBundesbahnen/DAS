import 'package:http_x/component.dart';

class const ConfirmRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<ConfirmResponse> call({
    required String messageId,
    required String deviceId,
  }) async {
    final url = Uri.https(baseUrl, 'driver/v1/departures/confirm/$messageId/$deviceId');
    final response = await httpClient.post(url);

    return ConfirmResponse.fromHttpResponse(response);
  }
}

class const ConfirmResponse({required final Map<String, String> headers}) {
  factory ConfirmResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return ConfirmResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }
}
