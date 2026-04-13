import 'package:json_annotation/json_annotation.dart';

part 'app_version_setting_dto.g.dart';

@JsonSerializable()
class AppVersionSettingDto {
  AppVersionSettingDto({required this.expired, required this.expiryDate});

  factory AppVersionSettingDto.fromJson(Map<String, dynamic> json) {
    return _$AppVersionSettingDtoFromJson(json);
  }

  final bool expired;
  final DateTime expiryDate;
}
