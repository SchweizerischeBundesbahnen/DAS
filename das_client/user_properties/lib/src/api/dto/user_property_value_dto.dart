import 'package:json_annotation/json_annotation.dart';

part 'user_property_value_dto.g.dart';

@JsonSerializable()
class UserPropertyValueDto({
  required final Object? value,
  final DateTime? lastModifiedAt,
}) {
  factory UserPropertyValueDto.fromJson(Object? json) => switch (json) {
    final Map<String, dynamic> map when map.containsKey('lastModifiedAt') => _$UserPropertyValueDtoFromJson(map),
    _ => UserPropertyValueDto(value: json),
  };

  Map<String, dynamic> toJson() => _$UserPropertyValueDtoToJson(this);
}
