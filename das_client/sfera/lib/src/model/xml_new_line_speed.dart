import 'package:sfera/src/model/line_speed.dart';
import 'package:sfera/src/model/network_specific_parameter.dart';
import 'package:sfera/src/model/nsp_xml_element.dart';

class XmlNewLineSpeed extends NetworkSpecificParameter with NspXmlElement<LineSpeed> {
  static const String elementName = 'xmlNewLineSpeed';

  XmlNewLineSpeed({super.attributes, super.children, super.value});
}
