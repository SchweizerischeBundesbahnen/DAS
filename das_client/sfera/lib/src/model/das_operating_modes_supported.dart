import 'package:sfera/src/model/enums/das_architecture.dart';
import 'package:sfera/src/model/enums/das_connectivity.dart';
import 'package:sfera/src/model/enums/das_driving_mode.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

class DasOperatingModesSupported extends SferaXmlElement {
  static const String elementType = 'DAS_OperatingModesSupported';

  DasOperatingModesSupported({super.type = elementType, super.attributes, super.children, super.value});

  factory DasOperatingModesSupported.create(
      DasDrivingMode drivingMode, DasArchitecture architecture, DasConnectivity connectivity) {
    final operatingMode = DasOperatingModesSupported();
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
