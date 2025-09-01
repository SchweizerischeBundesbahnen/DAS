import 'package:json_annotation/json_annotation.dart';
import 'package:settings/src/api/dto/settings_dto.dart';

part 'settings_response_dto.g.dart';

@JsonSerializable()
class SettingsResponseDto {
  SettingsResponseDto({required this.data});

  factory SettingsResponseDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsResponseDtoFromJson(json);
  }

  final List<SettingsDto> data;

  Map<String, dynamic> toJson() => _$SettingsResponseDtoToJson(this);
}
