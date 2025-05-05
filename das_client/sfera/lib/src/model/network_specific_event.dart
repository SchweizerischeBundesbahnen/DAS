import 'package:sfera/src/model/nsp.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/ux_testing_nse.dart';

class NetworkSpecificEvent extends Nsp {
  static const String elementType = 'NetworkSpecificEvent';

  NetworkSpecificEvent({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificEvent.from({Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    final groupName = children?.where((it) => it.type == Nsp.groupNameElement).firstOrNull;
    if (groupName?.value == UxTestingNse.elementName) {
      return UxTestingNse(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificEvent(attributes: attributes, children: children, value: value);
  }
}
