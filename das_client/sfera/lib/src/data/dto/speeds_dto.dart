import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';

class SpeedsDto extends SferaXmlElementDto {
  static const String elementType = 'speeds';

  SpeedsDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<VelocityDto> get velocities => children.whereType<VelocityDto>();
}
