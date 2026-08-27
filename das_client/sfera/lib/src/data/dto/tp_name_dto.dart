import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TpNameDto({super.type = elementType, super.attributes, super.children, super.value}) extends SferaXmlElementDto {
  static const String elementType = 'TP_Name';

  String get name => attributes['name']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && super.validate();
  }
}
