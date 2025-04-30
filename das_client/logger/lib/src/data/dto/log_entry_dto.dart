import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'log_entry_dto.g.dart';

@JsonSerializable()
class LogEntryDto {
  LogEntryDto({
    required this.time,
    required this.source,
    required this.message,
    required this.level,
    required this.metadata,
  });

  final double time;
  final String source;
  final String message;
  final String level;
  final Map<String, dynamic> metadata;

  factory LogEntryDto.fromJson(Map<String, dynamic> json) {
    return _$LogEntryDtoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LogEntryDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = JsonEncoder.withIndent(pretty ? ' ' * 2 : null);
    return encoder.convert(json);
  }
}
