import 'package:sfera/src/data/dto/enums/das_architecture.dart';
import 'package:sfera/src/data/dto/enums/das_connectivity.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class DasOperatingModesSelected extends SferaXmlElement {
  static const String elementType = 'DAS_OperatingModeSelected';

  DasOperatingModesSelected({super.type = elementType, super.attributes, super.children, super.value});

  DasArchitecture get architecture => XmlEnum.valueOf(DasArchitecture.values, attributes['DAS_architecture']!)!;

  DasConnectivity get connectivity => XmlEnum.valueOf(DasConnectivity.values, attributes['DAS_connectivity']!)!;

  @override
  bool validate() {
    return validateHasAttributeInRange('DAS_architecture', XmlEnum.values(DasArchitecture.values)) &&
        validateHasAttributeInRange('DAS_connectivity', XmlEnum.values(DasConnectivity.values)) &&
        super.validate();
  }
}
