import 'package:json_annotation/json_annotation.dart';
import 'package:settings/src/api/dto/app_version_expiration_dto.dart';
import 'package:settings/src/api/dto/company_dto.dart';
import 'package:settings/src/api/dto/logging_setting_dto.dart';
import 'package:settings/src/api/dto/preload_dto.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDto({
  required final LoggingSettingDto logging,
  required final List<RuFeatureDto> ruFeatures,
  required final List<CompanyDto> companies,
  required final PreloadDto preload,
  required final AppVersionExpirationDto currentAppVersion,
}) {
  factory SettingsDto.fromJson(Map<String, dynamic> json) {
    return _$SettingsDtoFromJson(json);
  }
}
