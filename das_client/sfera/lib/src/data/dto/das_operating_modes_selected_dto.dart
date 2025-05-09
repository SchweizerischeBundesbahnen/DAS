import 'package:sfera/src/data/dto/enums/das_architecture_dto.dart';
import 'package:sfera/src/data/dto/enums/das_connectivity_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class DasOperatingModesSelectedDto extends SferaXmlElementDto {
  static const String elementType = 'DAS_OperatingModeSelected';

  DasOperatingModesSelectedDto({super.type = elementType, super.attributes, super.children, super.value});

  DasArchitectureDto get architecture => XmlEnum.valueOf(DasArchitectureDto.values, attributes['DAS_architecture']!)!;

  DasConnectivityDto get connectivity => XmlEnum.valueOf(DasConnectivityDto.values, attributes['DAS_connectivity']!)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('DAS_architecture', XmlEnum.values(DasArchitectureDto.values)) &&
        validateHasAttributeInRange('DAS_connectivity', XmlEnum.values(DasConnectivityDto.values)) &&
        super.validate();
  }
}
