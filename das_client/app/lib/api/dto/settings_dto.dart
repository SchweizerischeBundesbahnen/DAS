import 'package:app/api/dto/logging_setting_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDto {
  SettingsDto({required this.loggingSetting});

  factory SettingsDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsDtoFromJson(json);
  }

  final LoggingSettingDto loggingSetting;

  Map<String, dynamic> toJson() => _$SettingsDtoToJson(this);
}
