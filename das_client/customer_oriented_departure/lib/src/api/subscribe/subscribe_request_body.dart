import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'subscribe_request_body.g.dart';

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

  @JsonKey(toJson: _dateTimeToUtcIso8601)
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => _$SubscribeRequestBodyToJson(this);

  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = pretty ? JsonEncoder.withIndent(' ' * 2) : JsonEncoder();
    return encoder.convert(json);
  }

  @override
  String toString() {
    return 'SubscribeRequestBody{type: $type, evu: $evu, driver: $driver, messageId: $messageId, zugnr: $zugnr, deviceId: $deviceId, pushToken: $pushToken, expiresAt: $expiresAt}';
  }
}

String _dateTimeToUtcIso8601(DateTime dateTime) => dateTime.toUtc().toIso8601String();
