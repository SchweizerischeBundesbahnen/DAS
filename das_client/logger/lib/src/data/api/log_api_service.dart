import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';

class LogApiService {
  LogApiService({required this.baseUrl, this.httpClient});

  final String baseUrl;
  final Client? httpClient;

  SendLogsRequest get sendLogs => SendLogsRequest(httpClient: httpClient ?? _getOrNull<Client>(), baseUrl: baseUrl);

  static T? _getOrNull<T extends Object>() {
    try {
      return GetIt.I.get<T>();
    } catch (e) {
      return null;
    }
  }
}
