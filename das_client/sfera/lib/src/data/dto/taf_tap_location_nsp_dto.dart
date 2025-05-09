import 'package:sfera/src/data/dto/line_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_speed_nsp_dto.dart';

class TafTapLocationNspDto extends NspDto {
  static const String elementType = 'TAF_TAP_Location_NSP';

  TafTapLocationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TafTapLocationNspDto.from(
      {Map<String, String>? attributes, List<SferaXmlElementDto>? children, String? value}) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == StationSpeedNspDto.elementName) {
      return StationSpeedNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == NewLineSpeedTafTapLocationDto.elementName) {
      return NewLineSpeedTafTapLocationDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == LineFootNotesNspDto.elementName) {
      return LineFootNotesNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == OpFootNotesNspDto.elementName) {
      return OpFootNotesNspDto(attributes: attributes, children: children, value: value);
    }
    return TafTapLocationNspDto(attributes: attributes, children: children, value: value);
  }
}
