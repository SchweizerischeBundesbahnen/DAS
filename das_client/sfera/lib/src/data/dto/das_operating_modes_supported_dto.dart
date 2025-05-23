import 'package:sfera/src/data/dto/enums/das_architecture_dto.dart';
import 'package:sfera/src/data/dto/enums/das_connectivity_dto.dart';
import 'package:sfera/src/data/dto/enums/das_driving_mode_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class DasOperatingModesSupportedDto extends SferaXmlElementDto {
  static const String elementType = 'DAS_OperatingModesSupported';

  DasOperatingModesSupportedDto({super.type = elementType, super.attributes, super.children, super.value});

  factory DasOperatingModesSupportedDto.create(
    DasDrivingModeDto drivingMode,
    DasArchitectureDto architecture,
    DasConnectivityDto connectivity,
  ) {
    final operatingMode = DasOperatingModesSupportedDto();
    operatingMode.attributes['DAS_drivingMode'] = drivingMode.xmlValue;
    operatingMode.attributes['DAS_architecture'] = architecture.xmlValue;
    operatingMode.attributes['DAS_connectivity'] = connectivity.xmlValue;
    return operatingMode;
  }

  @override
  bool validate() {
    return validateHasAttribute('DAS_drivingMode') &&
        validateHasAttribute('DAS_architecture') &&
        validateHasAttribute('DAS_connectivity') &&
        super.validate();
  }
}
