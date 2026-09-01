import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';

class SpeedsDto({super.type = elementType, super.attributes, super.children, super.value}) extends SferaXmlElementDto {
  static const String elementType = 'speeds';

  Iterable<VelocityDto> get velocities => children.whereType<VelocityDto>();
}
