import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class TpName extends SferaXmlElement {
  static const String elementType = 'TP_Name';

  TpName({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && super.validate();
  }
}
