import 'package:sfera/src/data/dto/curve_speed_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';

class XmlCurveSpeedDto({super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto
    with NspXmlElementDto<CurveSpeedDto> {
  static const String elementName = 'xmlCurveSpeed';
}
