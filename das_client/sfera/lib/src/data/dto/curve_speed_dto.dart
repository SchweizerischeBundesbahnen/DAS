import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/speeds_dto.dart';

class CurveSpeedDto extends SferaXmlElementDto {
  static const String elementType = 'curveSpeed';

  CurveSpeedDto({super.type = elementType, super.attributes, super.children, super.value});

  SpeedsDto? get speeds => children.whereType<SpeedsDto>().firstOrNull;

  String? get text => attributes['text'];

  String? get comment => attributes['comment'];
}
