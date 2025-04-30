import 'package:app/sfera/src/model/das_operating_modes_selected.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';

class HandshakeAcknowledgement extends SferaXmlElement {
  static const String elementType = 'HandshakeAcknowledgement';

  HandshakeAcknowledgement({super.type = elementType, super.attributes, super.children, super.value});

  DasOperatingModesSelected get operationModeSelected => children.whereType<DasOperatingModesSelected>().first;

  @override
  bool validate() {
    return validateHasChildOfType<DasOperatingModesSelected>() && super.validate();
  }
}
