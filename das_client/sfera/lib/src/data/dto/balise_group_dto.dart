import 'package:sfera/src/data/dto/balise_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class BaliseGroupDto extends SferaXmlElementDto {
  static const String elementType = 'BaliseGroup';

  BaliseGroupDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<BaliseDto> get balise => children.whereType<BaliseDto>();
}
