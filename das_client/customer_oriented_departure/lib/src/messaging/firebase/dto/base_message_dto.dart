import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'base_message_dto.g.dart';

@JsonSerializable()
class BaseMessageDto {
  BaseMessageDto({required this.messageId});

  factory BaseMessageDto.fromJson(Map<String, dynamic> json) {
    return _$BaseMessageDtoFromJson(json);
  }

  factory BaseMessageDto.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return BaseMessageDto.fromJson(json);
  }

  final String messageId;
}
