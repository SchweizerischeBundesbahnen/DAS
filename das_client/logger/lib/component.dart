import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/das_log_tree.dart';
import 'package:logger/src/data/local/logger_cache_service.dart';
import 'package:logger/src/data/logger_repo_impl.dart';
import 'package:logger/src/data/logging_api/logger_service.dart';

export 'package:logger/src/log_entry.dart';

// TODO: Fix logging code
class LoggerComponent {
  const LoggerComponent._();

  static LogTree createDasLogTree({
    required String baseUrl,
    required Client httpClient,
  }) {
    final remoteService = LoggerService(baseUrl: baseUrl, httpClient: httpClient);
    final loggerRepo = LoggerRepoImpl(cacheService: LoggerCacheService(), remoteService: remoteService);
    return DasLogTree(loggerRepo: loggerRepo);
  }
}
