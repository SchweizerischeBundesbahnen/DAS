import 'dart:io';

import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';

class LogFileDto {
  LogFileDto({
    required this.logEntries,
    required this.file,
  });

  final Iterable<SplunkLogEntryDto> logEntries;
  final File file;
}
