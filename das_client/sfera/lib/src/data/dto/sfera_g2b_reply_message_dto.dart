import 'package:sfera/src/data/dto/g2b_reply_payload_dto.dart';
import 'package:sfera/src/data/dto/handshake_acknowledgement_dto.dart';
import 'package:sfera/src/data/dto/handshake_reject_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SferaG2bReplyMessageDto extends SferaXmlElementDto {
  static const String elementType = 'SFERA_G2B_ReplyMessage';

  SferaG2bReplyMessageDto({super.type = elementType, super.attributes, super.children, super.value});

  MessageHeaderDto get messageHeader => children.whereType<MessageHeaderDto>().first;

  G2bReplyPayloadDto? get payload => children.whereType<G2bReplyPayloadDto>().firstOrNull;

  HandshakeAcknowledgementDto? get handshakeAcknowledgement =>
      children.whereType<HandshakeAcknowledgementDto>().firstOrNull;

  HandshakeRejectDto? get handshakeReject => children.whereType<HandshakeRejectDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<MessageHeaderDto>() &&
        validateHasAnyChildOfType([
          G2bReplyPayloadDto.elementType,
          HandshakeAcknowledgementDto.elementType,
          HandshakeRejectDto.elementType,
        ]) &&
        super.validate();
  }
}
