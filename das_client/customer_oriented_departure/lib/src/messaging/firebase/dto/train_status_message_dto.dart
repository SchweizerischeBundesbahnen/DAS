import 'dart:convert';

import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_status_message_dto.g.dart';

@JsonSerializable()
class TrainStatusMessageDto extends BaseMessageDto {
  TrainStatusMessageDto({
    required super.messageId,
    required this.zugnr,
    required this.bp,
    required this.status,
  });

  factory TrainStatusMessageDto.fromJson(Map<String, dynamic> json) {
    return _$TrainStatusMessageDtoFromJson(json);
  }

  factory TrainStatusMessageDto.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return TrainStatusMessageDto.fromJson(json);
  }

  final String zugnr;
  final String bp;
  final String status;
}
