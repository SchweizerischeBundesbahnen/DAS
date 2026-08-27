import 'package:json_annotation/json_annotation.dart';

part 'external_link_translation_dto.g.dart';

@JsonSerializable()
class ExternalLinkTranslationDto({required final String? title, required final String? link}) {
  factory ExternalLinkTranslationDto.fromJson(Map<String, dynamic> json) => _$ExternalLinkTranslationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalLinkTranslationDtoToJson(this);
}
