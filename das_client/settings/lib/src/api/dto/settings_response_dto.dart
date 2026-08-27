import 'package:json_annotation/json_annotation.dart';
import 'package:settings/src/api/dto/settings_dto.dart';

part 'settings_response_dto.g.dart';

@JsonSerializable()
class SettingsResponseDto({required final List<SettingsDto> data}) {
  factory SettingsResponseDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsResponseDtoFromJson(json);
  }
}
