import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class VirtualBalisePosition extends SferaXmlElement {
  static const String elementType = 'VirtualBalisePosition';

  VirtualBalisePosition({super.type = elementType, super.attributes, super.children, super.value});

  String get latitude => attributes['latitude']!;

  String get longitude => attributes['longitude']!;

  String? get altitude => attributes['altitude']!;

  @override
  bool validate() {
    return validateHasAttribute('latitude') && validateHasAttribute('longitude') && super.validate();
  }
}
