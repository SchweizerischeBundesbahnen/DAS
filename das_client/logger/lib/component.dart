import 'package:logger/src/das_logger.dart';
import 'package:logger/src/das_logger_impl.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/local/log_file_service_impl.dart';
import 'package:logger/src/data/logger_repo_impl.dart';

export 'package:logger/src/das_logger.dart';
export 'package:logger/src/log_entry.dart';
export 'package:logger/src/log_printer.dart';

class LoggerComponent {
  const LoggerComponent._();

  static DasLogger createDasLogger({
    required String deviceId,
    required String backendUrl,
  }) {
    final apiService = LogApiService(baseUrl: backendUrl);
    final loggerRepo = LoggerRepoImpl(fileService: LogFileServiceImpl(), apiService: apiService);
    return DasLoggerImpl(loggerRepo: loggerRepo, deviceId: deviceId);
  }
}
