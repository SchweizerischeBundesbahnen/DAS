import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class B2gEventPayload extends SferaXmlElement {
  static const String elementType = 'B2G_EventPayload';

  B2gEventPayload({super.type = elementType, super.attributes, super.children, super.value});
}
