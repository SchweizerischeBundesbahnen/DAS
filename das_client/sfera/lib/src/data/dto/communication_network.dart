import 'package:sfera/src/data/dto/enums/communication_network_type.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element.dart';

class CommunicationNetwork extends SferaSegmentXmlElement {
  static const String elementType = 'CommunicationNetwork';

  CommunicationNetwork({super.type = elementType, super.attributes, super.children, super.value});

  SferaCommunicationNetworkType get communicationNetworkType =>
      XmlEnum.valueOf(SferaCommunicationNetworkType.values, attributes['communicationNetworkType'])!;

  @override
  double get startLocation => super.startLocation!;

  @override
  double get endLocation => super.endLocation!;

  @override
  bool validate() {
    return validateHasAttribute('startLocation') &&
        validateHasAttribute('endLocation') &&
        validateHasAttribute('communicationNetworkType') &&
        super.validate();
  }
}
