import 'package:sfera/src/data/dto/enums/disturbance_msg_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class DisturbanceMsgNspDto extends NetworkSpecificParameterDto {
  static const String elementName = 'disturbanceMsg';

  DisturbanceMsgNspDto({super.type, super.attributes, super.children, super.value});

  DisturbanceMsgTypeDto get disturbanceMsgType => XmlEnum.valueOf(DisturbanceMsgTypeDto.values, nspValue)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(DisturbanceMsgTypeDto.values)) && super.validate();
  }
}
