import 'package:sfera/src/data/dto/graduated_speed_info_entity_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class GraduatedSpeedInfoDto extends SferaXmlElementDto {
  static const String elementType = 'entries';

  GraduatedSpeedInfoDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<GraduatedSpeedInfoEntityDto> get entities => children.whereType<GraduatedSpeedInfoEntityDto>();
}
