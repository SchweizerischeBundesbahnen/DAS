import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/station_speed_dto.dart';

class XmlStationSpeedDto extends NetworkSpecificParameterDto with NspXmlElementDto<StationSpeedDto> {
  static const String elementName = 'xmlStationSpeed';

  XmlStationSpeedDto({super.attributes, super.children, super.value});
}
