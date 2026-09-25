import 'package:json_annotation/json_annotation.dart';
import 'package:user_properties/src/api/dto/user_properties_dto.dart';

part 'user_properties_response_dto.g.dart';

@JsonSerializable()
class UserPropertiesResponseDto({required final List<UserPropertiesDto> data}) {
  factory UserPropertiesResponseDto.fromJson(Map<String, dynamic> json) => _$UserPropertiesResponseDtoFromJson(json);
}
