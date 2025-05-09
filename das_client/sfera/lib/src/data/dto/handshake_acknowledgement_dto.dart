import 'package:sfera/src/data/dto/das_operating_modes_selected_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class HandshakeAcknowledgementDto extends SferaXmlElementDto {
  static const String elementType = 'HandshakeAcknowledgement';

  HandshakeAcknowledgementDto({super.type = elementType, super.attributes, super.children, super.value});

  DasOperatingModesSelectedDto get operationModeSelected => children.whereType<DasOperatingModesSelectedDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<DasOperatingModesSelectedDto>() && super.validate();
  }
}
