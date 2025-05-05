import 'package:sfera/src/data/dto/enums/track_equipment_type.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';

class TrackEquipmentTypeWrapper extends NetworkSpecificParameter {
  static const String elementName = 'trackEquipmentType';

  TrackEquipmentTypeWrapper({super.type, super.attributes, super.children, super.value});

  SferaTrackEquipmentType get unwrapped => XmlEnum.valueOf(SferaTrackEquipmentType.values, attributes['value']!)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(SferaTrackEquipmentType.values)) && super.validate();
  }
}
