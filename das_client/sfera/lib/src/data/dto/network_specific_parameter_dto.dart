import 'package:sfera/src/data/dto/amount_tram_signals_dto.dart';
import 'package:sfera/src/data/dto/id_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/track_equipment_type_wrapper_dto.dart';
import 'package:sfera/src/data/dto/xml_curve_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/xml_line_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_op_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/xml_station_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_track_foot_notes_dto.dart';

class NetworkSpecificParameterDto extends SferaXmlElementDto {
  static const String elementType = 'NetworkSpecificParameter';

  NetworkSpecificParameterDto({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificParameterDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    if (attributes?['name'] == XmlNewLineSpeedDto.elementName) {
      return XmlNewLineSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == TrackEquipmentTypeWrapperDto.elementName) {
      return TrackEquipmentTypeWrapperDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlCurveSpeedDto.elementName) {
      return XmlCurveSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlStationSpeedDto.elementName) {
      return XmlStationSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlGraduatedSpeedInfoDto.elementName) {
      return XmlGraduatedSpeedInfoDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == AmountTramSignalsDto.elementName) {
      return AmountTramSignalsDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlLineFootNotesDto.elementName) {
      return XmlLineFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlOpFootNotesDto.elementName) {
      return XmlOpFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlTrackFootNotesDto.elementName) {
      return XmlTrackFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == IdNetworkSpecificParameterDto.elementName) {
      return IdNetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == SpeedNetworkSpecificParameterDto.elementName) {
      return SpeedNetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
  }

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }

  @override
  String toString() {
    return 'NetworkSpecificParameter{name: $name, nspValue: $nspValue}';
  }
}

// extensions

extension NetworkSpecificParametersExtension on Iterable<NetworkSpecificParameterDto> {
  NetworkSpecificParameterDto? withName(String name) => where((it) => it.name == name).firstOrNull;
}
