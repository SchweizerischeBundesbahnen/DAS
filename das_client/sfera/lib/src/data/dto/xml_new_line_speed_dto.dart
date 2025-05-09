import 'package:sfera/src/data/dto/line_speed_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';

class XmlNewLineSpeedDto extends NetworkSpecificParameterDto with NspXmlElementDto<LineSpeedDto> {
  static const String elementName = 'xmlNewLineSpeed';

  XmlNewLineSpeedDto({super.attributes, super.children, super.value});
}
