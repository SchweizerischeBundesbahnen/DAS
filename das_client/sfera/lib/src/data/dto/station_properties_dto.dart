import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_property_dto.dart';

class StationPropertiesDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'stationProperties';

  Iterable<StationPropertyDto> get properties => children.whereType<StationPropertyDto>();
}
