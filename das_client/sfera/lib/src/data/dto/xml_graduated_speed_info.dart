import 'package:sfera/src/data/dto/graduated_speed_info.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';

class XmlGraduatedSpeedInfo extends NetworkSpecificParameter with NspXmlElement<GraduatedSpeedInfo> {
  static const String elementName = 'xmlGraduatedSpeedInfo';

  XmlGraduatedSpeedInfo({super.attributes, super.children, super.value});
}
