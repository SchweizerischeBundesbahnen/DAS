import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class SignalFunction extends SferaXmlElement {
  static const String elementType = 'SignalFunction';

  SignalFunction({super.type = elementType, super.attributes, super.children, super.value});
}
