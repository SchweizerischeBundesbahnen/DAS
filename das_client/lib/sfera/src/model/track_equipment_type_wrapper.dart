import 'package:das_client/sfera/src/model/enums/track_equipment_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';

class TrackEquipmentTypeWrapper extends NetworkSpecificParameter {
  static const String elementName = 'trackEquipmentType';

  TrackEquipmentTypeWrapper({super.type, super.attributes, super.children, super.value});

  SferaTrackEquipmentType get unwrapped => XmlEnum.valueOf(SferaTrackEquipmentType.values, attributes['value']!)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(SferaTrackEquipmentType.values)) && super.validate();
  }
}