import 'package:sfera/src/data/dto/departure_dispatch_notification_event_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/ux_testing_nse_dto.dart';
import 'package:sfera/src/data/dto/warn_app_msg_dto.dart';

class NetworkSpecificEventDto extends NspDto {
  static const String elementType = 'NetworkSpecificEvent';

  NetworkSpecificEventDto({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificEventDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == UxTestingNseDto.elementName) {
      return UxTestingNseDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == WarnAppMsgDto.elementName) {
      return WarnAppMsgDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == DepartureDispatchNotificationEventDto.elementName) {
      return DepartureDispatchNotificationEventDto(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificEventDto(attributes: attributes, children: children, value: value);
  }
}
