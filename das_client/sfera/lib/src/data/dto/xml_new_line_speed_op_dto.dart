import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/new_line_speed_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';

class XmlNewLineSpeedOPDto({super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto
    with NspXmlElementDto<NewLineSpeedDto> {
  static const String elementName = 'xmlNewLineSpeedOP';
}
