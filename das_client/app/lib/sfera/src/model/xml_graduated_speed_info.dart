import 'package:app/sfera/src/model/graduated_speed_info.dart';
import 'package:app/sfera/src/model/network_specific_parameter.dart';
import 'package:app/sfera/src/model/nsp_xml_element.dart';

class XmlGraduatedSpeedInfo extends NetworkSpecificParameter with NspXmlElement<GraduatedSpeedInfo> {
  static const String elementName = 'xmlGraduatedSpeedInfo';

  XmlGraduatedSpeedInfo({super.attributes, super.children, super.value});
}
