import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/src/api/dto/ru_indication_content_dto.dart';
import 'package:ru_indications/src/model/ru_indication.dart';

part 'ru_indication_location_dto.g.dart';

final _log = Logger('RuIndicationLocationDto');

@JsonSerializable()
class RuIndicationLocationDto({
  required final String tafTapLocationReference,
  required final List<RuIndicationContentDto> ruIndicationContents,
}) {
  factory fromJson(Map<String, dynamic> json) => _$RuIndicationLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RuIndicationLocationDtoToJson(this);
}

extension RuIndicationLocationDtoX on RuIndicationLocationDto {
  Iterable<RuIndication> toRuIndications(Map<int, String> locationReferences) =>
      ruIndicationContents.map<Iterable<RuIndication>>((content) {
        final entries = locationReferences.entries.where((it) => it.value == tafTapLocationReference);
        return entries.map((entry) => RuIndication(title: content.title, text: content.text, order: entry.key));
      }).flattened;
}
