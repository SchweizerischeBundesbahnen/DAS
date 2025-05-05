import 'package:sfera/src/data/dto/curve_speed.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';

class XmlCurveSpeed extends NetworkSpecificParameter with NspXmlElement<CurveSpeed> {
  static const String elementName = 'xmlCurveSpeed';

  XmlCurveSpeed({super.attributes, super.children, super.value});
}
