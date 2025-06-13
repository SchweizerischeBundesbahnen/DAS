import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';

class LogApiService {
  LogApiService({required this.baseUrl});

  final String baseUrl;

  SendLogsRequest get sendLogs => SendLogsRequest(httpClient: _getOrNull<Client>(), baseUrl: baseUrl);

  static T? _getOrNull<T extends Object>() {
    try {
      return GetIt.I.get<T>();
    } catch (e) {
      return null;
    }
  }
}
