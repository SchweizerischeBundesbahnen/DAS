import 'package:sfera/src/data/dto/b2g_event_payload_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/session_termination_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SferaB2gEventMessageDto extends SferaXmlElementDto {
  static const String elementType = 'SFERA_B2G_EventMessage';

  SferaB2gEventMessageDto({super.type = elementType, super.attributes, super.children, super.value});

  factory SferaB2gEventMessageDto.createSessionTermination({required MessageHeaderDto messageHeader}) {
    final eventMessage = SferaB2gEventMessageDto();
    eventMessage.children.add(messageHeader);

    final sessionTermination = B2gEventPayloadDto();
    sessionTermination.children.add(SessionTerminationDto());

    eventMessage.children.add(sessionTermination);

    return eventMessage;
  }

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeaderDto>() && validateHasChildOfType<B2gEventPayloadDto>() && super.validate();
  }
}
