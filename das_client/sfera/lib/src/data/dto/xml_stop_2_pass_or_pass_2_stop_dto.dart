import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_2_pass_or_pass_2_stop_dto.dart';

class XmlStop2PassOrPass2StopDto extends NetworkSpecificParameterDto with NspXmlElementDto<Stop2PassOrPass2StopDto> {
  static const String elementName = 'xmlStop2PassOrPass2Stop';

  XmlStop2PassOrPass2StopDto({super.attributes, super.children, super.value});
}
