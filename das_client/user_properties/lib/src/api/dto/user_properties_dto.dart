import 'package:json_annotation/json_annotation.dart';
import 'package:user_properties/src/api/dto/user_properties_options_dto.dart';

part 'user_properties_dto.g.dart';

@JsonSerializable()
class UserPropertiesDto({
  required final UserPropertiesOptionsDto userPropertiesOptionsDto,
}) {
  factory UserPropertiesDto.fromJson(Map<String, dynamic> json) => _$UserPropertiesDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserPropertiesDtoToJson(this);
}
