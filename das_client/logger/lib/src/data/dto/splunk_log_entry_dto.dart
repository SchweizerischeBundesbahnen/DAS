import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'splunk_log_entry_dto.g.dart';

@JsonSerializable()
class SplunkLogEntryDto {
  static String jsonIndent = '  ';

  final double time;

  SplunkLogEntryDto({
    required this.time,
    required this.event,
    required Map<String, dynamic> fields,
    String? level,
    this.source = 'das-client',
  }) {
    this.fields = Map.of(fields);
    if (level != null) {
      this.fields['level'] = level;
    }
  }

  final String source;
  final String event;
  late final Map<String, dynamic> fields;

  factory SplunkLogEntryDto.fromJson(Map<String, dynamic> json) {
    return _$SplunkLogEntryDtoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SplunkLogEntryDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = JsonEncoder.withIndent(pretty ? jsonIndent : null);
    return encoder.convert(json);
  }
}
