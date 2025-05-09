import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SessionTerminationDto extends SferaXmlElementDto {
  static const String elementType = 'SessionTermination';

  SessionTerminationDto({super.type = elementType, super.attributes, super.children, super.value});
}
