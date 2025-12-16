import 'package:sfera/src/data/dto/disturbance_msg_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';

class DisturbanceMsgEventDto extends NetworkSpecificEventDto {
  static const String elementName = 'lmlcMsg';

  DisturbanceMsgEventDto({super.type, super.attributes, super.children, super.value});

  DisturbanceMsgNspDto get disturbanceMsgNsp => parameters.whereType<DisturbanceMsgNspDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<DisturbanceMsgNspDto>() && super.validate();
  }
}
