import 'package:json_annotation/json_annotation.dart';

part 'logging_setting_dto.g.dart';

@JsonSerializable()
class LoggingSettingDto({required final String url, required final String token}) {
  factory fromJson(Map<String, dynamic> json) {
    return _$LoggingSettingDtoFromJson(json);
  }
}
