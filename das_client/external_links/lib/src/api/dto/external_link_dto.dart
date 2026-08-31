import 'package:core_data/component.dart';
import 'package:external_links/src/api/dto/external_link_translation_dto.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_link_dto.g.dart';

@JsonSerializable()
class ExternalLinkDto({
  required final int id,
  required final List<String> companies,
  required final ExternalLinkTranslationDto? de,
  required final ExternalLinkTranslationDto? fr,
  required final ExternalLinkTranslationDto? it,
  required final DateTime lastModifiedAt,
  required final String lastModifiedBy,
}) {
  factory fromJson(Map<String, dynamic> json) => _$ExternalLinkDtoFromJson(json);

  ExternalLink toModel() {
    return ExternalLink(
      id: id,
      companies: companies,
      title: LocalizedString(
        de: de?.title,
        fr: fr?.title,
        it: it?.title,
      ),
      link: LocalizedString(
        de: de?.link,
        fr: fr?.link,
        it: it?.link,
      ),
      lastModifiedAt: lastModifiedAt,
      lastModifiedBy: lastModifiedBy,
    );
  }

  Map<String, dynamic> toJson() => _$ExternalLinkDtoToJson(this);
}
