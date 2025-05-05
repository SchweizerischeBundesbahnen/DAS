import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';
import 'package:sfera/src/data/dto/station_speed.dart';

class XmlStationSpeed extends NetworkSpecificParameter with NspXmlElement<StationSpeed> {
  static const String elementName = 'xmlStationSpeed';

  XmlStationSpeed({super.attributes, super.children, super.value});
}
