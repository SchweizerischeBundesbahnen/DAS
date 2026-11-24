import 'package:das_logger/src/das_logger.dart';
import 'package:das_logger/src/das_logger_impl.dart';
import 'package:das_logger/src/data/api/log_api_service.dart';
import 'package:das_logger/src/data/local/log_file_service_impl.dart';
import 'package:das_logger/src/data/logger_repo_impl.dart';

export 'package:das_logger/src/das_logger.dart';
export 'package:das_logger/src/log_endpoint.dart';
export 'package:das_logger/src/log_entry.dart';
export 'package:das_logger/src/log_printer.dart';

class LoggerComponent._() {
  static DASLogger createDASLogger({required String deviceId}) {
    final apiService = LogApiService();
    final loggerRepo = LoggerRepoImpl(fileService: LogFileServiceImpl(), apiService: apiService);
    return DASLoggerImpl(loggerRepo: loggerRepo, deviceId: deviceId);
  }
}
