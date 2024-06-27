import 'package:das_client/model/sfera/g2b_reply_payload.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class SferaG2bReplyMessage extends SferaXmlElement {
  static const String elementType = "SFERA_G2B_ReplyMessage";

  SferaG2bReplyMessage({required super.type, super.attributes, super.children, super.value});

  MessageHeader get messageHeader => children.whereType<MessageHeader>().first;

  G2bReplyPayload get payload => children.whereType<G2bReplyPayload>().first;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeader>() && validateHasChildOfType<G2bReplyPayload>() && super.validate();
  }
}
