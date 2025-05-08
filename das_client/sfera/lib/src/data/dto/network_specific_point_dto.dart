import 'package:sfera/src/data/dto/curve_point_network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/track_foot_notes_nsp_dto.dart';
import 'package:sfera/src/data/dto/whistle_network_specific_point_dto.dart';

class NetworkSpecificPointDto extends NspDto {
  static const String elementType = 'NetworkSpecificPoint';

  NetworkSpecificPointDto({super.type = elementType, super.attributes, super.children, super.value});

  double get location => double.parse(attributes['location']!);

  factory NetworkSpecificPointDto.from(
      {Map<String, String>? attributes, List<SferaXmlElementDto>? children, String? value}) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == NewLineSpeedNetworkSpecificPointDto.elementName) {
      return NewLineSpeedNetworkSpecificPointDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == CurvePointNetworkSpecificPointDto.elementName) {
      return CurvePointNetworkSpecificPointDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == WhistleNetworkSpecificPointDto.elementName) {
      return WhistleNetworkSpecificPointDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == TrackFootNotesNspDto.elementName) {
      return TrackFootNotesNspDto(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificPointDto(attributes: attributes, children: children, value: value);
  }

  @override
  bool validate() {
    return validateHasAttribute('location') && super.validate();
  }
}
