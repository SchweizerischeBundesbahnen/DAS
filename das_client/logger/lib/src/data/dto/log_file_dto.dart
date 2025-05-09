import 'dart:io';

import 'package:logger/src/data/dto/log_entry_dto.dart';

class LogFileDto {
  LogFileDto({
    required this.logEntries,
    required this.file,
  });

  final Iterable<LogEntryDto> logEntries;
  final File file;
}
