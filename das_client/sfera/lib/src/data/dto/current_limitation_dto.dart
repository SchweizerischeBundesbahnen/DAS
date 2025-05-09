import 'package:sfera/src/data/dto/current_limitation_change_dto.dart';
import 'package:sfera/src/data/dto/current_limitation_start_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class CurrentLimitationDto extends SferaXmlElementDto {
  static const String elementType = 'CurrentLimitation';

  CurrentLimitationDto({super.type = elementType, super.attributes, super.children, super.value});

  CurrentLimitationStartDto get currentLimitationStart => children.whereType<CurrentLimitationStartDto>().first;

  Iterable<CurrentLimitationChangeDto> get currentLimitationChanges => children.whereType<CurrentLimitationChangeDto>();

  @override
  bool validate() {
    return validateHasChildOfType<CurrentLimitationStartDto>() && super.validate();
  }
}
