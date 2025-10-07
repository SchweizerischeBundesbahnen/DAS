import 'package:sfera/src/data/dto/enums/track_equipment_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class TrackEquipmentTypeWrapperDto extends NetworkSpecificParameterDto {
  static const String elementName = 'trackEquipmentType';

  TrackEquipmentTypeWrapperDto({super.type, super.attributes, super.children, super.value});

  SferaTrackEquipmentTypeDto get unwrapped => XmlEnum.valueOf(SferaTrackEquipmentTypeDto.values, nspValue)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(SferaTrackEquipmentTypeDto.values)) && super.validate();
  }
}
