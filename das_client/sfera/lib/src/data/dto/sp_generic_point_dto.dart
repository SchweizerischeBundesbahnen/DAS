import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

abstract class SpGenericPointDto({required super.type, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  double get location => double.parse(attributes['location']!);

  String? get identifier => attributes['identifier'];

  @override
  bool validate() {
    return validateHasAttributeDouble('location') && super.validate();
  }
}
