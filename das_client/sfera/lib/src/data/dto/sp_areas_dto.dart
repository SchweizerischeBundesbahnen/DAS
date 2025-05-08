import 'package:sfera/src/data/dto/network_specific_area_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_dto.dart';

class SpAreasDto extends SferaXmlElementDto {
  static const String elementType = 'SP_Areas';
  static const String _nonStandardTrackEquipmentName = 'nonStandardTrackEquipment';
  static const String _tramAreaName = 'tramArea';

  SpAreasDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TafTapLocationDto> get tafTapLocations => children.whereType<TafTapLocationDto>();

  Iterable<NetworkSpecificAreaDto> get nonStandardTrackEquipments =>
      children.whereType<NetworkSpecificAreaDto>().where((it) => it.groupName == _nonStandardTrackEquipmentName);

  Iterable<NetworkSpecificAreaDto> get tramAreas =>
      children.whereType<NetworkSpecificAreaDto>().where((it) => it.groupName == _tramAreaName);
}
