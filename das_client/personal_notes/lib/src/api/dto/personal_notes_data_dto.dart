import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';

part 'personal_notes_data_dto.g.dart';

@JsonSerializable()
class PersonalNotesDataDto({required final List<PersonalNoteDto> data}) {
  factory fromJson(Map<String, dynamic> json) => _$PersonalNotesDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalNotesDataDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }
}
