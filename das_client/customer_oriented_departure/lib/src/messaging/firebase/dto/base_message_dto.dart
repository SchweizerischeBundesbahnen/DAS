import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'base_message_dto.g.dart';

@JsonSerializable()
class BaseMessageDto({required final String messageId}) {
  factory fromJson(Map<String, dynamic> json) => _$BaseMessageDtoFromJson(json);

  factory fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return BaseMessageDto.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$BaseMessageDtoToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }
}
