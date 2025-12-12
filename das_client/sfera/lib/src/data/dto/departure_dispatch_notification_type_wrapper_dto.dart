import 'package:sfera/src/data/dto/enums/departure_dispatch_notification_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class DepartureDispatchNotificationTypeWrapperDto extends NetworkSpecificParameterDto {
  static const String elementName = 'message';

  DepartureDispatchNotificationTypeWrapperDto({super.type, super.attributes, super.children, super.value});

  DepartureDispatchNotificationTypeDto get unwrapped =>
      XmlEnum.valueOf(DepartureDispatchNotificationTypeDto.values, nspValue)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(DepartureDispatchNotificationTypeDto.values)) &&
        super.validate();
  }
}
