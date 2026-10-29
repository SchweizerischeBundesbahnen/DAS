import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'splunk_log_entry_dto.g.dart';

@JsonSerializable()
class SplunkLogEntryDto({
  required final double time,
  required final String event,
  required Map<String, dynamic> fields,
  String? level,
  final String source = 'das-client',
}) {
  static String jsonIndent = '  ';

  this {
    this.fields = Map.of(fields);
    if (level != null) {
      this.fields['level'] = level;
    }
  }

  late final Map<String, dynamic> fields;

  factory fromJson(Map<String, dynamic> json) => _$SplunkLogEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SplunkLogEntryDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = JsonEncoder.withIndent(pretty ? jsonIndent : null);
    return encoder.convert(json);
  }
}
