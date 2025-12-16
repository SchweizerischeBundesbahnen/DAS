import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/departure_dispatch_notification_event.dart';

enum DepartureDispatchNotificationTypeDto implements XmlEnum {
  prepareForDepartureLong(
    xmlValue: 'PREPARE_FOR_DEPARTURE_LONG',
    type: .prepareForDepartureLong,
  ),
  prepareForDepartureMiddle(
    xmlValue: 'PREPARE_FOR_DEPARTURE_MIDDLE',
    type: .prepareForDepartureMiddle,
  ),
  prepareForDepartureShort(
    xmlValue: 'PREPARE_FOR_DEPARTURE_SHORT',
    type: .prepareForDepartureShort,
  ),
  prepareForDeparture(
    xmlValue: 'PREPARE_FOR_DEPARTURE',
    type: .prepareForDeparture,
  ),
  departureProvisionWithdrawn(
    xmlValue: 'DEPARTURE_PROVISION_WITHDRAWN',
    type: .departureProvisionWithdrawn,
  )
  ;

  const DepartureDispatchNotificationTypeDto({
    required this.xmlValue,
    required this.type,
  });

  @override
  final String xmlValue;

  final DepartureDispatchNotificationType type;
}
