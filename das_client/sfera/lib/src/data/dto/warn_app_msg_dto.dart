import 'package:sfera/src/data/dto/network_specific_event_dto.dart';

class WarnAppMsgDto({super.type, super.attributes, super.children, super.value}) extends NetworkSpecificEventDto {
  static const String groupNameValue = 'warnAppMsg';

  @override
  String toString() {
    return 'WarnAppMsg';
  }
}
