import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/dto/log_file_dto.dart';

abstract class LogFileService {
  Future<Iterable<LogFileDto>> get completedLogFiles;

  Future<void> writeLog(LogEntryDto log);

  Future<bool> get hasCompletedLogFiles;

  Future<void> deleteLogFile(LogFileDto file);
}
