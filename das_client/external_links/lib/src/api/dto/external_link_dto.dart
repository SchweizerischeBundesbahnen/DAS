import 'package:external_links/src/api/dto/external_link_translation_dto.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/localized_string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_link_dto.g.dart';

@JsonSerializable()
class ExternalLinkDto {
  ExternalLinkDto({
    required this.id,
    required this.companies,
    required this.de,
    required this.fr,
    required this.it,
    required this.lastModifiedAt,
    required this.lastModifiedBy,
  });

  factory ExternalLinkDto.fromJson(Map<String, dynamic> json) => _$ExternalLinkDtoFromJson(json);

  final int id;
  final List<String> companies;
  final ExternalLinkTranslationDto? de;
  final ExternalLinkTranslationDto? fr;
  final ExternalLinkTranslationDto? it;
  final DateTime lastModifiedAt;
  final String lastModifiedBy;

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
