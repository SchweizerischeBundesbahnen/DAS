import 'package:sfera/src/model/sfera_xml_element.dart';

class Text extends SferaXmlElement {
  static const String elementType = 'text';

  Text({required this.xmlValue, super.type = elementType, super.attributes, super.children, super.value});

  final String xmlValue;
}
