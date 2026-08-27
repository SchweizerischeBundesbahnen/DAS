import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SignalFunctionDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'SignalFunction';
}
