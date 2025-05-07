import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/das_log_tree.dart';
import 'package:logger/src/data/api/api_service.dart';
import 'package:logger/src/data/local/log_file_service_impl.dart';
import 'package:logger/src/data/logger_repo_impl.dart';

export 'package:logger/src/log_entry.dart';

// TODO: Fix logging code
class LoggerComponent {
  const LoggerComponent._();

  static LogTree createDasLogTree({
    required String baseUrl,
    required Client httpClient,
    required String deviceId,
  }) {
    final remoteService = ApiService(baseUrl: baseUrl, httpClient: httpClient);
    final loggerRepo = LoggerRepoImpl(cacheService: LogFileServiceImpl(), remoteService: remoteService);
    return DasLogTree(loggerRepo: loggerRepo, deviceId: deviceId);
  }
}
