import 'package:sfera/src/data/dto/delay_dto.dart';
import 'package:sfera/src/data/dto/position_speed_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TrainLocationInformationDto extends SferaXmlElementDto {
  static const String elementType = 'TrainLocationInformation';

  TrainLocationInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  DelayDto get delay => children.whereType<DelayDto>().first;

  PositionSpeedDto? get positionSpeed => children.whereType<PositionSpeedDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<DelayDto>() && super.validate();
  }
}
