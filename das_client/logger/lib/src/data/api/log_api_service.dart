import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:logger/src/data/api/endpoint/send_logs.dart';

class LogApiService {
  LogApiService({Client? httpClient}) : _httpClient = httpClient ?? HttpXComponent.createHttpClient();

  final Client _httpClient;

  SendLogsRequest get sendLogs =>
      SendLogsRequest(httpClient: _httpClient, url: _logEndpoint?.loggingUrl, token: _logEndpoint?.loggingToken);

  LogEndpoint? get _logEndpoint => _getOrNull<LogEndpoint>();

  static T? _getOrNull<T extends Object>() {
    try {
      return GetIt.I.get<T>();
    } catch (e) {
      return null;
    }
  }
}
