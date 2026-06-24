import 'package:json_annotation/json_annotation.dart';
import 'package:ru_indications/src/api/dto/ru_indication_location_dto.dart';

part 'ru_indication_matches_response_dto.g.dart';

@JsonSerializable()
class RuIndicationMatchesResponseDto {
  RuIndicationMatchesResponseDto({required this.data});

  factory RuIndicationMatchesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RuIndicationMatchesResponseDtoFromJson(json);

  final List<RuIndicationLocationDto> data;

  Map<String, dynamic> toJson() => _$RuIndicationMatchesResponseDtoToJson(this);
}

