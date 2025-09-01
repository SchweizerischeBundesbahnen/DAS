import 'package:json_annotation/json_annotation.dart';

part 'logging_setting_dto.g.dart';

@JsonSerializable()
class LoggingSettingDto {
  LoggingSettingDto({required this.url, required this.token});

  factory LoggingSettingDto.fromJson(Map<String, dynamic> json) {
    return _$LoggingSettingDtoFromJson(json);
  }

  final String url;
  final String token;

  Map<String, dynamic> toJson() => _$LoggingSettingDtoToJson(this);
}
