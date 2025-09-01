import 'dart:io';

import 'package:logger/src/data/dto/log_entry_dto.dart';

abstract class LogFileService {
  Future<Iterable<File>> get completedLogFiles;

  Future<void> writeLog(LogEntryDto log);

  Future<void> completeCurrentFile();

  Future<bool> get hasCompletedLogFiles;

  Future<void> deleteLogFile(File file);
}
