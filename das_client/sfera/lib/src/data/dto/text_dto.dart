import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TextDto extends SferaXmlElementDto {
  static const String elementType = 'text';

  TextDto({required this.xmlValue, super.type = elementType, super.attributes, super.children, super.value});

  final String xmlValue;
}
