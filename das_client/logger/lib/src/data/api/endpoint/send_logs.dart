import 'dart:io';

import 'package:http_x/component.dart';
import 'package:logger/src/data/api/send_logs_exception.dart';

class const SendLogsRequest({
  required final Client httpClient,
  final String? url,
  final String? token,
}) {
  /// Sends the given log file to the remote endpoint.
  ///
  /// Throws a [TransientSendLogsException] or [PermanentSendLogsException] on failure.
  Future<SendLogsResponse> call(File logFile) async {
    if (this.url == null || token == null) {
      throw const TransientSendLogsException('logging url or token not configured');
    }

    final logFileContent = logFile.readAsStringSync();

    final url = Uri.parse(this.url!);
    final Response response;
    try {
      response = await httpClient.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Splunk $token'},
        body: '[$logFileContent]',
      );
    } catch (ex) {
      throw TransientSendLogsException(ex);
    }
    return SendLogsResponse.fromHttpResponse(response);
  }
}

class const SendLogsResponse({required final Map<String, String> headers}) {
  factory fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return SendLogsResponse(headers: response.headers);
    }
    // Failure
    final exception = HttpException.fromResponse(response);
    if (_isTransient(status)) throw TransientSendLogsException(exception);
    throw PermanentSendLogsException(exception);
  }

  /// Server errors may resolve themselves, as may these client errors:
  /// 401/403 (misconfigured token, logs can be sent once fixed), 408 (request timeout) and 429 (throttling).
  static bool _isTransient(int statusCode) =>
      statusCode >= 500 ||
      statusCode == HttpStatus.unauthorized ||
      statusCode == HttpStatus.forbidden ||
      statusCode == HttpStatus.requestTimeout ||
      statusCode == HttpStatus.tooManyRequests;
}
