import 'package:sfera/src/model/sfera_xml_element.dart';

class SessionTermination extends SferaXmlElement {
  static const String elementType = 'SessionTermination';

  SessionTermination({super.type = elementType, super.attributes, super.children, super.value});
}
