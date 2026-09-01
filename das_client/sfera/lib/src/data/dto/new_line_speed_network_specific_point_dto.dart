import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_line_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_op_dto.dart';

class NewLineSpeedNetworkSpecificPointDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificPointDto {
  static const String groupNameValue = 'newLineSpeed';

  XmlNewLineSpeedOPDto? get xmlNewLineSpeedOP => parameters.whereType<XmlNewLineSpeedOPDto>().firstOrNull;

  XmlNewLineSpeedLineDto? get xmlNewLineSpeedLine => parameters.whereType<XmlNewLineSpeedLineDto>().firstOrNull;
}
