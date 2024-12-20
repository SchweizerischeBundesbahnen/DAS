import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class Delay extends SferaXmlElement {
  static const String elementType = 'Delay';

  Delay({super.type = elementType, super.attributes, super.children, super.value});

  String get delay => attributes['Delay']!;

  @override
  bool validate() {
    return validateHasAttribute('Delay') && super.validate();
  }
}
