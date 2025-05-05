import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class OtherContactType extends SferaXmlElement {
  static const String elementType = 'OtherContactType';

  OtherContactType({super.type = elementType, super.attributes, super.children, super.value});

  String? get contactIdentifier => attributes['contactIdentifier'];
}
