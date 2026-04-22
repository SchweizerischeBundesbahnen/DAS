import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'request_body.g.dart';

@JsonSerializable()
class SubscribeRequestBody {
  SubscribeRequestBody({
    required this.type,
    required this.evu,
    required this.driver,
    required this.messageId,
    required this.zugnr,
    required this.deviceId,
    required this.pushToken,
    required this.expiresAt,
  });

  factory SubscribeRequestBody.fromJson(Map<String, dynamic> json) {
    return _$SubscribeRequestBodyFromJson(json);
  }

  factory SubscribeRequestBody.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return SubscribeRequestBody.fromJson(json);
  }

  final String type;
  final String evu;
  final bool driver;
  final String messageId;
  final String zugnr;
  final String deviceId;
  final String pushToken;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => _$SubscribeRequestBodyToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }

  @override
  String toString() {
    final jsonString = toJsonString(pretty: true);
    return 'SubscribeRequestBody $jsonString';
  }
}
