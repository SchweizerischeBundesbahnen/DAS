import 'dart:io';

import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';

class LogFileDto({
  required final Iterable<SplunkLogEntryDto> logEntries,
  required final File file,
});
