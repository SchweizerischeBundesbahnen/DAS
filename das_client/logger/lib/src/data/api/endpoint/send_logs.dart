import 'package:http_x/component.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/mappers.dart';

class SendLogsRequest {
  const SendLogsRequest({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client? httpClient;

  Future<SendLogsResponse> call(Iterable<LogEntryDto> logEntries) async {
    if (httpClient == null) {
      return Future.error('HTTP client is not initialized');
    }

    final url = Uri.https(baseUrl, '/v1/logging/logs');
    final response = await httpClient!.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: logEntries.toJsonString(),
    );
    return SendLogsResponse.fromHttpResponse(response);
  }
}

class SendLogsResponse {
  const SendLogsResponse({required this.headers});

  factory SendLogsResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status == 200;
    if (isSuccess) {
      return SendLogsResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
}
