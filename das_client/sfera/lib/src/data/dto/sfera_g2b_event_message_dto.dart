import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SferaG2bEventMessageDto extends SferaXmlElementDto {
  static const String elementType = 'SFERA_G2B_EventMessage';

  SferaG2bEventMessageDto({super.type = elementType, super.attributes, super.children, super.value});

  MessageHeaderDto get messageHeader => children.whereType<MessageHeaderDto>().first;

  G2bEventPayloadDto? get payload => children.whereType<G2bEventPayloadDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeaderDto>() && validateHasChildOfType<G2bEventPayloadDto>() && super.validate();
  }
}
