import 'package:sfera/src/data/dto/b2g_request_dto.dart';
import 'package:sfera/src/data/dto/handshake_request_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SferaB2gRequestMessageDto extends SferaXmlElementDto {
  static const String elementType = 'SFERA_B2G_RequestMessage';

  SferaB2gRequestMessageDto({super.type = elementType, super.attributes, super.children, super.value});

  factory SferaB2gRequestMessageDto.create(
    MessageHeaderDto header, {
    HandshakeRequestDto? handshakeRequest,
    B2gRequestDto? b2gRequest,
  }) {
    final requestMessage = SferaB2gRequestMessageDto();
    requestMessage.children.add(header);
    if (handshakeRequest != null) {
      requestMessage.children.add(handshakeRequest);
    }
    if (b2gRequest != null) {
      requestMessage.children.add(b2gRequest);
    }

    return requestMessage;
  }

  MessageHeaderDto get messageHeader => children.whereType<MessageHeaderDto>().first;

  HandshakeRequestDto? get handshakeRequest => children.whereType<HandshakeRequestDto>().firstOrNull;

  B2gRequestDto? get b2gRequest => children.whereType<B2gRequestDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeaderDto>() &&
        validateHasAnyChildOfType([B2gRequestDto.elementType, HandshakeRequestDto.elementType]) &&
        super.validate();
  }
}
