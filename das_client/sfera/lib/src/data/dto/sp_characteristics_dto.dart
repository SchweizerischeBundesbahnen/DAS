import 'package:sfera/src/data/dto/current_limitation_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SpCharacteristicsDto extends SferaXmlElementDto {
  static const String elementType = 'SP_Characteristics';

  SpCharacteristicsDto({super.type = elementType, super.attributes, super.children, super.value});

  CurrentLimitationDto? get currentLimitation => children.whereType<CurrentLimitationDto>().firstOrNull;
}
