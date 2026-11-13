import 'dart:io';

import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

SferaG2bReplyMessageDto correlateReplyMessage(SferaG2bReplyMessageDto message, String correlationId) =>
    SferaG2bReplyMessageDto(
      type: message.type,
      attributes: message.attributes,
      children: [
        MessageHeaderDto(
          attributes: {...message.messageHeader.attributes, 'correlation_ID': correlationId},
          children: message.messageHeader.children,
        ),
        ...message.children.where((child) => child is! MessageHeaderDto),
      ],
      value: message.value,
    );

SferaG2bReplyMessageDto parseReplyMessage(String path) =>
    SferaReplyParser.parse<SferaG2bReplyMessageDto>(File(path).readAsStringSync());
