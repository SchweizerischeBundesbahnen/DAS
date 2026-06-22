import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/localized_string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_links_response_dto.g.dart';

@JsonSerializable()
class ExternalLinksResponseDto {
  ExternalLinksResponseDto({required this.data});

  factory ExternalLinksResponseDto.fromJson(Map<String, dynamic> json) => _$ExternalLinksResponseDtoFromJson(json);

  final List<ExternalLinkDto> data;

  Map<String, dynamic> toJson() => _$ExternalLinksResponseDtoToJson(this);
}

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

@JsonSerializable()
class ExternalLinkTranslationDto {
  ExternalLinkTranslationDto({required this.title, required this.link});

  factory ExternalLinkTranslationDto.fromJson(Map<String, dynamic> json) => _$ExternalLinkTranslationDtoFromJson(json);

  final String? title;
  final String? link;

  Map<String, dynamic> toJson() => _$ExternalLinkTranslationDtoToJson(this);
}
