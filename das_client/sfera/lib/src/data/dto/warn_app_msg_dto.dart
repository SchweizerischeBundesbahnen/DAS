import 'package:sfera/src/data/dto/network_specific_event_dto.dart';

class WarnAppMsgDto extends NetworkSpecificEventDto {
  static const String elementName = 'warnAppMsg';

  WarnAppMsgDto({super.type, super.attributes, super.children, super.value});

  @override
  String toString() {
    return 'WarnAppMsg';
  }
}
