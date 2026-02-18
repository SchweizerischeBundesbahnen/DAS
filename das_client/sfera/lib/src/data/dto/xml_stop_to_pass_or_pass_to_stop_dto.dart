import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_to_pass_or_pass_to_stop_dto.dart';

class XmlStopToPassOrPassToStopDto extends NetworkSpecificParameterDto
    with NspXmlElementDto<StopToPassOrPassToStopDto> {
  static const String elementName = 'xmlStop2PassOrPass2Stop';

  XmlStopToPassOrPassToStopDto({super.attributes, super.children, super.value});
}
