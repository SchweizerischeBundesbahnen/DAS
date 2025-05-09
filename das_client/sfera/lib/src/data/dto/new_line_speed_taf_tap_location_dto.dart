import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_dto.dart';

class NewLineSpeedTafTapLocationDto extends TafTapLocationNspDto {
  static const String elementName = 'newLineSpeed';

  NewLineSpeedTafTapLocationDto({super.type, super.attributes, super.children, super.value});

  XmlNewLineSpeedDto get xmlNewLineSpeed => parameters.whereType<XmlNewLineSpeedDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlNewLineSpeedDto>() && super.validate();
  }
}
