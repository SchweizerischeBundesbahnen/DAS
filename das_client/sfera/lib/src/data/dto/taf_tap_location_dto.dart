import 'package:sfera/src/data/dto/enums/taf_tap_location_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/line_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_ident_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class TafTapLocationDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'TAF_TAP_Location';

  TafTapLocationDto({super.type = elementType, super.attributes, super.children, super.value});

  TafTapLocationIdentDto get locationIdent => children.whereType<TafTapLocationIdentDto>().first;

  TafTapLocationTypeDto? get locationType =>
      XmlEnum.valueOf<TafTapLocationTypeDto>(TafTapLocationTypeDto.values, attributes['TAF_TAP_location_type']);

  String get abbreviation => attributes['TAF_TAP_location_abbreviation'] ?? '';

  Iterable<TafTapLocationNspDto> get nsp => children.whereType<TafTapLocationNspDto>();

  StationSpeedNspDto? get stationSpeed => children.whereType<StationSpeedNspDto>().firstOrNull;

  NewLineSpeedTafTapLocationDto? get newLineSpeed => children.whereType<NewLineSpeedTafTapLocationDto>().firstOrNull;

  OpFootNotesNspDto? get opFootNotes => children.whereType<OpFootNotesNspDto>().firstOrNull;

  LineFootNotesNspDto? get lineFootNotes => children.whereType<LineFootNotesNspDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<TafTapLocationIdentDto>() && super.validate();
  }
}
