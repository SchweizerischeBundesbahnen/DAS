import 'package:external_links/src/api/dto/external_link_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_links_response_dto.g.dart';

@JsonSerializable()
class ExternalLinksResponseDto({required final List<ExternalLinkDto> data}) {
  factory ExternalLinksResponseDto.fromJson(Map<String, dynamic> json) => _$ExternalLinksResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalLinksResponseDtoToJson(this);
}
