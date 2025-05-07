import 'package:http_x/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';

class LogApiService {
  LogApiService({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  SendLogsRequest get sendLogs => SendLogsRequest(httpClient: httpClient, baseUrl: baseUrl);
}
