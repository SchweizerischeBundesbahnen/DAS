import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class KmReference extends SferaXmlElement {
  static const String elementType = 'KM_Reference';

  KmReference({super.type = elementType, super.attributes, super.children, super.value});

  double get kmRef => double.parse(attributes['kmRef']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('kmRef') && super.validate();
  }
}
