import 'package:json_annotation/json_annotation.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';

part 'user_property_dto.g.dart';

@JsonSerializable()
class UserPropertyDto({
  required final String key,
  required final Object? value,
  final DateTime? lastUpdated,
}) {
  factory UserPropertyDto.fromJson(Map<String, dynamic> json) => _$UserPropertyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserPropertyDtoToJson(this);

  UserPropertyModel toModel() => UserPropertyModel(key: key, value: value, lastUpdated: lastUpdated);
}
