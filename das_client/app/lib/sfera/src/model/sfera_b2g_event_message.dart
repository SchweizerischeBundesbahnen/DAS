import 'package:app/sfera/src/model/b2g_event_payload.dart';
import 'package:app/sfera/src/model/message_header.dart';
import 'package:app/sfera/src/model/session_termination.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';

class SferaB2gEventMessage extends SferaXmlElement {
  static const String elementType = 'SFERA_B2G_EventMessage';

  SferaB2gEventMessage({super.type = elementType, super.attributes, super.children, super.value});

  factory SferaB2gEventMessage.createSessionTermination({required MessageHeader messageHeader}) {
    final eventMessage = SferaB2gEventMessage();
    eventMessage.children.add(messageHeader);

    final sessionTermination = B2gEventPayload();
    sessionTermination.children.add(SessionTermination());

    eventMessage.children.add(sessionTermination);

    return eventMessage;
  }

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeader>() && validateHasChildOfType<B2gEventPayload>() && super.validate();
  }
}
