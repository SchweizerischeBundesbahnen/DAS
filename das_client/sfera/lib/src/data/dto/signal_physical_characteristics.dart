import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class SignalPhysicalCharacteristics extends SferaXmlElement {
  static const String elementType = 'SignalPhysicalCharacteristics';

  SignalPhysicalCharacteristics({super.type = elementType, super.attributes, super.children, super.value});

  String get visualIdentifier => attributes['visualIdentifier']!;

  @override
  bool validate() {
    return validateHasAttribute('visualIdentifier') && super.validate();
  }
}
