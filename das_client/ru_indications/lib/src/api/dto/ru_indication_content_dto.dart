import 'package:json_annotation/json_annotation.dart';

part 'ru_indication_content_dto.g.dart';

@JsonSerializable()
class RuIndicationContentDto({
  required final String title,
  required final String text,
}) {
  factory RuIndicationContentDto.fromJson(Map<String, dynamic> json) => _$RuIndicationContentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RuIndicationContentDtoToJson(this);
}
