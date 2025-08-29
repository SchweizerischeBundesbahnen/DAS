import 'package:http_x/component.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/mappers.dart';

class SendLogsRequest {
  const SendLogsRequest({required this.httpClient, this.url, this.token});

  final Client httpClient;
  final String? url;
  final String? token;

  Future<SendLogsResponse> call(Iterable<LogEntryDto> logEntries) async {
    if (this.url == null || token == null) {
      return Future.error('logging url or token not configured');
    }

    final url = Uri.parse(this.url!);
    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Splunk $token'},
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
