import 'package:json_annotation/json_annotation.dart';

part 'external_link_translation_dto.g.dart';

@JsonSerializable()
class ExternalLinkTranslationDto {
  ExternalLinkTranslationDto({required this.title, required this.link});

  factory ExternalLinkTranslationDto.fromJson(Map<String, dynamic> json) => _$ExternalLinkTranslationDtoFromJson(json);

  final String? title;
  final String? link;

  Map<String, dynamic> toJson() => _$ExternalLinkTranslationDtoToJson(this);
}
