import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_properties_dto.dart';

class XmlStationPropertyDto extends NetworkSpecificParameterDto with NspXmlElementDto<StationPropertiesDto> {
  static const String elementName = 'xmlStationProperty';

  XmlStationPropertyDto({super.attributes, super.children, super.value});
}
