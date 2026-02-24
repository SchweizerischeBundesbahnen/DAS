import 'package:sfera/src/data/dto/departure_auth_nsp_dto.dart';
import 'package:sfera/src/data/dto/line_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_property_nsp_dto.dart';
import 'package:sfera/src/data/dto/station_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_route_table_data_nsp_dto.dart';

class TafTapLocationNspDto extends NspDto {
  static const String elementType = 'TAF_TAP_Location_NSP';

  TafTapLocationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TafTapLocationNspDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == StationSpeedNspDto.groupNameValue) {
      return StationSpeedNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == NewLineSpeedTafTapLocationDto.groupNameValue) {
      return NewLineSpeedTafTapLocationDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == LineFootNotesNspDto.groupNameValue) {
      return LineFootNotesNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == OpFootNotesNspDto.groupNameValue) {
      return OpFootNotesNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == StationPropertyNspDto.groupNameValue) {
      return StationPropertyNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == TafTapRouteTableDataNspDto.groupNameValue) {
      return TafTapRouteTableDataNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value?.startsWith(LocalRegulationNspDto.groupNameValueStart) == true) {
      return LocalRegulationNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == DepartureAuthNspDto.groupNameValue) {
      return DepartureAuthNspDto(attributes: attributes, children: children, value: value);
    }
    return TafTapLocationNspDto(attributes: attributes, children: children, value: value);
  }
}

extension SferaXmlElementDtoIterableExtension on Iterable<SferaXmlElementDto> {
  Iterable<NetworkSpecificParameterDto> whereNspWithName(String name) =>
      whereType<NetworkSpecificParameterDto>().where((it) => it.name == name);
}
