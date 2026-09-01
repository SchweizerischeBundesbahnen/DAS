import 'package:sfera/src/data/dto/enums/operational_indication_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class OperationalIndicationTypeNspDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'type';

  OperationalIndicationTypeDto get operationalIndicationType =>
      XmlEnum.valueOf<OperationalIndicationTypeDto>(OperationalIndicationTypeDto.values, nspValue)!;

  @override
  bool validate() =>
      validateHasAttributeInRange('value', XmlEnum.values(OperationalIndicationTypeDto.values)) && super.validate();
}
