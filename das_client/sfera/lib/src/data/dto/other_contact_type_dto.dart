import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class OtherContactTypeDto extends SferaXmlElementDto {
  static const String elementType = 'OtherContactType';

  OtherContactTypeDto({super.type = elementType, super.attributes, super.children, super.value});

  String? get contactIdentifier => attributes['contactIdentifier'];
}
