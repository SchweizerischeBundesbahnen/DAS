import 'dart:convert';

import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_status_message_dto.g.dart';

@JsonSerializable()
class TrainStatusMessageDto({
  required super.messageId,
  required final String zugnr,
  required final String status,
  final String? bp,
}) extends BaseMessageDto {
  factory fromJson(Map<String, dynamic> json) => _$TrainStatusMessageDtoFromJson(json);

  factory fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return TrainStatusMessageDto.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$TrainStatusMessageDtoToJson(this);
}
