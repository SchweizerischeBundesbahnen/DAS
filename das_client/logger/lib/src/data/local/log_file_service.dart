import 'dart:io';

import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';

abstract class LogFileService {
  Future<Iterable<File>> get completedLogFiles;

  Future<void> writeLog(SplunkLogEntryDto log);

  Future<void> completeCurrentFile();

  Future<bool> get hasCompletedLogFiles;

  Future<void> deleteLogFile(File file);
}
