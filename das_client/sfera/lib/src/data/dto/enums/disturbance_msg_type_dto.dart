import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/disturbance_event.dart';

enum DisturbanceMsgTypeDto implements XmlEnum {
  start(xmlValue: 'grid_power_overlad', type: DisturbanceEventType.start),
  end(xmlValue: 'grid_power_overload_end', type: DisturbanceEventType.end)
  ;

  const DisturbanceMsgTypeDto({
    required this.xmlValue,
    required this.type,
  });

  @override
  final String xmlValue;

  final DisturbanceEventType type;
}
