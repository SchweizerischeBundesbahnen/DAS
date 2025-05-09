import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class KmReferenceDto extends SferaXmlElementDto {
  static const String elementType = 'KM_Reference';

  KmReferenceDto({super.type = elementType, super.attributes, super.children, super.value});

  double get kmRef => double.parse(attributes['kmRef']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('kmRef') && super.validate();
  }
}
