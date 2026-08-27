import 'package:json_annotation/json_annotation.dart';
import 'package:settings/component.dart';

part 'app_version_expiration_dto.g.dart';

@JsonSerializable()
class AppVersionExpirationDto({
  required final bool expired,
  final DateTime? expiryDate,
}) {
  factory AppVersionExpirationDto.fromJson(Map<String, dynamic> json) {
    return _$AppVersionExpirationDtoFromJson(json);
  }
}

extension AppVersionExpirationDtoX on AppVersionExpirationDto {
  AppVersionExpiration toDomain() {
    return AppVersionExpiration(
      expired: expired,
      expiryDate: expiryDate,
    );
  }
}
