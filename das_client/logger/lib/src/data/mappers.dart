import 'dart:convert';

import 'package:logger/component.dart';
import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';

extension LogEntryX on LogEntry {
  SplunkLogEntryDto toDto() => SplunkLogEntryDto(
    time: time,
    event: message,
    level: level.name,
    fields: metadata,
  );
}

extension LogEntryDtoListX on Iterable<SplunkLogEntryDto> {
  String toJsonString({bool pretty = false}) {
    final jsonList = map((entry) => entry.toJson()).toList();
    final encoder = JsonEncoder.withIndent(pretty ? SplunkLogEntryDto.jsonIndent : null);
    return encoder.convert(jsonList);
  }
}
