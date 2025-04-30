import 'package:app/sfera/src/model/network_specific_parameter.dart';
import 'package:app/sfera/src/model/nsp_xml_element.dart';
import 'package:app/sfera/src/model/station_speed.dart';

class XmlStationSpeed extends NetworkSpecificParameter with NspXmlElement<StationSpeed> {
  static const String elementName = 'xmlStationSpeed';

  XmlStationSpeed({super.attributes, super.children, super.value});
}
