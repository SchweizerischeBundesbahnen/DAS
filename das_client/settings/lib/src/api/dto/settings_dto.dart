import 'package:json_annotation/json_annotation.dart';
import 'package:settings/src/api/dto/app_version_expiration_dto.dart';
import 'package:settings/src/api/dto/logging_setting_dto.dart';
import 'package:settings/src/api/dto/preload_dto.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDto {
  SettingsDto({
    required this.logging,
    required this.ruFeatures,
    required this.preload,
    required this.currentAppVersion,
  });

  factory SettingsDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsDtoFromJson(json);
  }

  final LoggingSettingDto logging;
  final List<RuFeatureDto> ruFeatures;
  final PreloadDto preload;
  final AppVersionExpirationDto currentAppVersion;
}
