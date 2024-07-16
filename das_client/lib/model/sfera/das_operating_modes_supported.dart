import 'package:das_client/model/sfera/enums/das_architecture.dart';
import 'package:das_client/model/sfera/enums/das_connectivity.dart';
import 'package:das_client/model/sfera/enums/das_driving_mode.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class DasOperatingModesSupported extends SferaXmlElement {
  static const String elementType = "DAS_OperatingModesSupported";

  DasOperatingModesSupported({super.type = elementType, super.attributes, super.children, super.value});

  factory DasOperatingModesSupported.create(
      DasDrivingMode drivingMode, DasArchitecture architecture, DasConnectivity connectivity) {
    final operatingMode = DasOperatingModesSupported();
    operatingMode.attributes["DAS_drivingMode"] = drivingMode.xmlValue;
    operatingMode.attributes["DAS_architecture"] = architecture.xmlValue;
    operatingMode.attributes["DAS_connectivity"] = connectivity.xmlValue;
    return operatingMode;
  }

  @override
  bool validate() {
    return validateHasAttribute("DAS_drivingMode") &&
        validateHasAttribute("DAS_architecture") &&
        validateHasAttribute("DAS_connectivity") &&
        super.validate();
  }
}
