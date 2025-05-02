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
  String toJsonString({bool pretty = false}) {
    final jsonList = this.map((entry) => entry.toJson()).toList();
    final encoder = JsonEncoder.withIndent(pretty ? ' ' * 2 : null);
    return encoder.convert(jsonList);
  }
}
