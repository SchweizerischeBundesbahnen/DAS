import 'package:das_client/sfera/src/model/curve_speed.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/nsp_xml_element.dart';

class XmlCurveSpeed extends NetworkSpecificParameter with NspXmlElement<CurveSpeed> {
  static const String elementName = 'xmlCurveSpeed';

  XmlCurveSpeed({super.attributes, super.children, super.value});
}
