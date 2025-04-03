import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class OtherContactType extends SferaXmlElement {
  static const String elementType = 'OtherContactType';

  OtherContactType({super.type = elementType, super.attributes, super.children, super.value});

  String? get contactIdentifier => attributes['contactIdentifier'];
}
