import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'formation_response_dto.g.dart';

@JsonSerializable()
class FormationResponseDto {
  FormationResponseDto({required this.data});

  factory FormationResponseDto.fromJson(Map<String, dynamic> json) {
    return _$FormationResponseDtoFromJson(json);
  }

  final List<FormationDto> data;

  Map<String, dynamic> toJson() => _$FormationResponseDtoToJson(this);
}
