import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_dto.dart';

class NewLineSpeedNetworkSpecificPointDto extends NetworkSpecificPointDto {
  static const String elementName = 'newLineSpeed';

  NewLineSpeedNetworkSpecificPointDto({super.type, super.attributes, super.children, super.value});

  XmlNewLineSpeedDto get xmlNewLineSpeed => parameters.whereType<XmlNewLineSpeedDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlNewLineSpeedDto>() && super.validate();
  }
}
