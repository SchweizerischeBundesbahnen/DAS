import 'package:sfera/src/data/dto/departure_dispatch_notification_type_wrapper_dto.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';

class DepartureDispatchNotificationEventDto extends NetworkSpecificEventDto {
  static const String groupNameValue = 'ddMsg';

  DepartureDispatchNotificationEventDto({super.type, super.attributes, super.children, super.value});

  DepartureDispatchNotificationTypeWrapperDto get message =>
      parameters.whereType<DepartureDispatchNotificationTypeWrapperDto>().first;

  @override
  String toString() {
    return 'DepartureDispatchNotificationEventDto{message: $message}';
  }

  @override
  bool validate() {
    return validateHasChildOfType<DepartureDispatchNotificationTypeWrapperDto>() && super.validate();
  }
}
