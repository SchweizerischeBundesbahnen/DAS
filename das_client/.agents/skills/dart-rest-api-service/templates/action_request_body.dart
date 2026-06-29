import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part '<action>_request_body.g.dart';

@JsonSerializable()
class ActionRequestBody {
  ActionRequestBody({
    required this.param1,
    required this.param2,
    // Add more fields as needed. Use @JsonKey(name: 'json_key') for custom JSON keys.
    // required this.expiresAt, // Example DateTime field — see @JsonKey below
  });

  factory ActionRequestBody.fromJson(Map<String, dynamic> json) {
    return _$ActionRequestBodyFromJson(json);
  }

  factory ActionRequestBody.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return ActionRequestBody.fromJson(json);
  }

  final String param1;
  final String param2;

  /// Example for DateTime serialization:
  /// @JsonKey(toJson: _dateTimeToUtcIso8601)
  /// final DateTime expiresAt;

  Map<String, dynamic> toJson() => _$ActionRequestBodyToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }

  @override
  String toString() {
    return 'ActionRequestBody{param1: $param1, param2: $param2}';
  }
}

/// Converts a DateTime to a UTC ISO 8601 string.
/// Use with: @JsonKey(toJson: _dateTimeToUtcIso8601)
String _dateTimeToUtcIso8601(DateTime dateTime) => dateTime.toUtc().toIso8601String();

