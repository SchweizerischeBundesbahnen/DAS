import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class SignalFunction extends SferaXmlElement {
  static const String elementType = 'SignalFunction';

  SignalFunction({super.type = elementType, super.attributes, super.children, super.value});
}
