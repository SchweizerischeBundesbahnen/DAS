import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/das_log_tree.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/local/log_file_service_impl.dart';
import 'package:logger/src/data/logger_repo_impl.dart';

export 'package:logger/src/log_entry.dart';

class LoggerComponent {
  const LoggerComponent._();

  static LogTree createDasLogTree({
    required String baseUrl,
    required Client httpClient,
    required String deviceId,
  }) {
    final remoteService = LogApiService(baseUrl: baseUrl, httpClient: httpClient);
    final loggerRepo = LoggerRepoImpl(fileService: LogFileServiceImpl(), apiService: remoteService);
    return DasLogTree(loggerRepo: loggerRepo, deviceId: deviceId);
  }
}
