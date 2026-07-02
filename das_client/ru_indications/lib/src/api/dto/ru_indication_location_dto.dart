import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/src/api/dto/ru_indication_content_dto.dart';
import 'package:ru_indications/src/model/ru_indication.dart';

part 'ru_indication_location_dto.g.dart';

final _log = Logger('RuIndicationLocationDto');

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
  Iterable<RuIndication> toRuIndications(Map<String, int> locationReferences) =>
      ruIndicationContents.map<RuIndication?>((content) {
        final order = locationReferences[tafTapLocationReference];
        if (order == null) {
          _log.warning('No order found for $tafTapLocationReference from $this');
          return null;
        }
        return RuIndication(title: content.title, text: content.text, order: order);
      }).nonNulls;
}
