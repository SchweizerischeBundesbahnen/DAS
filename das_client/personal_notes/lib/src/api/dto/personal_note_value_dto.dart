import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'personal_note_value_dto.g.dart';

@JsonSerializable()
class PersonalNoteValueDto({
  required final String text,
  required final bool showAsFootnote,
}) {
  factory PersonalNoteValueDto.fromJson(Map<String, dynamic> json) => _$PersonalNoteValueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalNoteValueDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }
}
