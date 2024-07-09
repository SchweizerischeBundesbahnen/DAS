import 'package:das_client/model/sfera/b2g_request.dart';
import 'package:das_client/model/sfera/handshake_request.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class SferaB2gRequestMessage extends SferaXmlElement {
  static const String elementType = "SFERA_B2G_RequestMessage";

  SferaB2gRequestMessage({super.type = elementType, super.attributes, super.children, super.value});

  factory SferaB2gRequestMessage.create(MessageHeader header, {HandshakeRequest? handshakeRequest, B2gRequest? b2gRequest}) {
    final requestMessage = SferaB2gRequestMessage();
    requestMessage.children.add(header);
    if (handshakeRequest != null) {
      requestMessage.children.add(handshakeRequest);
    }
    if (b2gRequest != null) {
      requestMessage.children.add(b2gRequest);
    }

    return requestMessage;
  }

  MessageHeader get messageHeader => children.whereType<MessageHeader>().first;

  HandshakeRequest? get handshakeRequest => children.whereType<HandshakeRequest>().firstOrNull;

  B2gRequest? get b2gRequest => children.whereType<B2gRequest>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeader>() &&
        validateHasAnyChildOfType([B2gRequest.elementType, HandshakeRequest.elementType]) &&
        super.validate();
  }
}
