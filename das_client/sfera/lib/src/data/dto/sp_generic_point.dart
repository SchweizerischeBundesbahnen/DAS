import 'package:sfera/src/data/dto/sfera_xml_element.dart';

abstract class SpGenericPoint extends SferaXmlElement {
  SpGenericPoint({required super.type, super.attributes, super.children, super.value});

  double get location => double.parse(attributes['location']!);

  String? get identifier => attributes['identifier'];

  @override
  bool validate() {
    return validateHasAttributeDouble('location') && super.validate();
  }
}
