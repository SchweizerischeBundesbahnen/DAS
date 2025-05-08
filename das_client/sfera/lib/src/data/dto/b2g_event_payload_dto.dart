import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class B2gEventPayloadDto extends SferaXmlElementDto {
  static const String elementType = 'B2G_EventPayload';

  B2gEventPayloadDto({super.type = elementType, super.attributes, super.children, super.value});
}
