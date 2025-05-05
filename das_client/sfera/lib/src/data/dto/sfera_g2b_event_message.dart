import 'package:sfera/src/data/dto/g2b_event_payload.dart';
import 'package:sfera/src/data/dto/message_header.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class SferaG2bEventMessage extends SferaXmlElement {
  static const String elementType = 'SFERA_G2B_EventMessage';

  SferaG2bEventMessage({super.type = elementType, super.attributes, super.children, super.value});

  MessageHeader get messageHeader => children.whereType<MessageHeader>().first;

  G2bEventPayload? get payload => children.whereType<G2bEventPayload>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeader>() && validateHasChildOfType<G2bEventPayload>() && super.validate();
  }
}
