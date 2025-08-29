import 'package:app/api/dto/settings_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_response_dto.g.dart';

@JsonSerializable()
class SettingsResponseDto {
  SettingsResponseDto({required this.settings});

  factory SettingsResponseDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsResponseDtoFromJson(json);
  }

  final List<SettingsDto> settings;

  Map<String, dynamic> toJson() => _$SettingsResponseDtoToJson(this);
}
