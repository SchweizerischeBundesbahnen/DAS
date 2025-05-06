import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';

class XmlGraduatedSpeedInfoDto extends NetworkSpecificParameterDto with NspXmlElementDto<GraduatedSpeedInfoDto> {
  static const String elementName = 'xmlGraduatedSpeedInfo';

  XmlGraduatedSpeedInfoDto({super.attributes, super.children, super.value});
}
