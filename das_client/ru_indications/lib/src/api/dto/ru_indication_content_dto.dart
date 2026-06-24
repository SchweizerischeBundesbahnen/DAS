import 'package:json_annotation/json_annotation.dart';
import 'package:ru_indications/src/model/ru_indication_content.dart';

part 'ru_indication_content_dto.g.dart';

@JsonSerializable()
class RuIndicationContentDto {
  RuIndicationContentDto({
    required this.title,
    required this.text,
  });

  factory RuIndicationContentDto.fromJson(Map<String, dynamic> json) => _$RuIndicationContentDtoFromJson(json);

  final String title;
  final String text;

  Map<String, dynamic> toJson() => _$RuIndicationContentDtoToJson(this);
}

extension RuIndicationContentDtoX on RuIndicationContentDto {
  RuIndicationContent toDomain() => RuIndicationContent(title: title, text: text);
}
