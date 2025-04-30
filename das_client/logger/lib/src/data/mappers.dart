import 'dart:convert';

import 'package:logger/component.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';

extension LogEntryX on LogEntry {
  LogEntryDto toDto() => LogEntryDto(
        time: time,
        source: source,
        message: message,
        level: level.name,
        metadata: metadata,
      );
}

extension LogEntryDtoListX on Iterable<LogEntryDto> {
  String toJsonString() => jsonEncode(this.map((entry) => entry.toJsonString()));
}
