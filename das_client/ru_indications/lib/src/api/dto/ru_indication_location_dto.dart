import 'package:json_annotation/json_annotation.dart';
import 'package:ru_indications/src/api/dto/ru_indication_content_dto.dart';
import 'package:ru_indications/src/model/ru_indication.dart';

part 'ru_indication_location_dto.g.dart';

@JsonSerializable()
class RuIndicationLocationDto {
  RuIndicationLocationDto({
    required this.tafTapLocationReference,
    required this.ruIndicationContents,
  });

  factory RuIndicationLocationDto.fromJson(Map<String, dynamic> json) => _$RuIndicationLocationDtoFromJson(json);

  final String tafTapLocationReference;
  final List<RuIndicationContentDto> ruIndicationContents;

  Map<String, dynamic> toJson() => _$RuIndicationLocationDtoToJson(this);
}

extension RuIndicationLocationDtoX on RuIndicationLocationDto {
  RuIndication toDomain() => RuIndication(
    tafTapLocationReference: tafTapLocationReference,
    ruIndicationContents: ruIndicationContents.map((e) => e.toDomain()).toList(),
  );
}
