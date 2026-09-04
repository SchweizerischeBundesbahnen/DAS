import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_op_dto.dart';

class NewLineSpeedTafTapLocationDto({super.type, super.attributes, super.children, super.value})
    extends TafTapLocationNspDto {
  static const String groupNameValue = 'newLineSpeed';

  XmlNewLineSpeedOPDto get xmlNewLineSpeed => parameters.whereType<XmlNewLineSpeedOPDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlNewLineSpeedOPDto>() && super.validate();
  }
}
