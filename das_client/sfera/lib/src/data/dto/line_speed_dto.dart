import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/speeds_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';

class LineSpeedDto extends SferaXmlElementDto {
  static const String elementType = 'lineSpeed';

  LineSpeedDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<VelocityDto> get velocities => children.whereType<VelocityDto>();

  SpeedsDto? get speeds => children.whereType<SpeedsDto>().firstOrNull;

  String? get text => attributes['text'];
}
