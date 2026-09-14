import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:personal_notes/src/api/dto/personal_note_value_dto.dart';
import 'package:personal_notes/src/model/personal_note.dart';

part 'personal_note_dto.g.dart';

@JsonSerializable()
class PersonalNoteDto({
  required final String key,
  required final PersonalNoteValueDto value,
  required final DateTime lastModifiedAt,
}) {
  factory PersonalNoteDto.fromJson(Map<String, dynamic> json) => _$PersonalNoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalNoteDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }
}

extension PersonalNoteDtoX on PersonalNoteDto {
  PersonalNote toDomain() {
    return PersonalNote(
      locationCode: key,
      lastModifiedAt: lastModifiedAt,
      text: value.text,
      showAsFootnote: value.showAsFootnote,
    );
  }
}

extension PersonalNoteX on PersonalNote {
  PersonalNoteDto toDto() {
    return PersonalNoteDto(
      key: locationCode,
      lastModifiedAt: lastModifiedAt,
      value: PersonalNoteValueDto(
        text: text,
        showAsFootnote: showAsFootnote,
      ),
    );
  }
}
