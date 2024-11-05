import 'package:das_client/sfera/src/model/enums/das_architecture.dart';
import 'package:das_client/sfera/src/model/enums/das_connectivity.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class DasOperatingModesSelected extends SferaXmlElement {
  static const String elementType = 'DAS_OperatingModeSelected';

  DasOperatingModesSelected({super.type = elementType, super.attributes, super.children, super.value});

  DasArchitecture get architecture => XmlEnum.valueOf(DasArchitecture.values, attributes['DAS_architecture']!)!;

  DasConnectivity get connectivity => XmlEnum.valueOf(DasConnectivity.values, attributes['DAS_connectivity']!)!;

  @override
  bool validate() {
    return validateHasEnumAttribute(DasArchitecture.values, 'DAS_architecture') &&
        validateHasEnumAttribute(DasConnectivity.values, 'DAS_connectivity') &&
        super.validate();
  }
}
