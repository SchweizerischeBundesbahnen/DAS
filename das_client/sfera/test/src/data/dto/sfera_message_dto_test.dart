import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/g2b_reply_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

void main() {
  test('logSummary_whenReplyMessageWithPayload_thenContainsHeaderIdsAndDistinctContentTypes', () {
    final message = SferaG2bReplyMessageDto(
      children: [
        MessageHeaderDto(attributes: {'message_ID': 'msg-1', 'correlation_ID': 'corr-1'}),
        G2bReplyPayloadDto(children: [JourneyProfileDto(), SegmentProfileDto(), SegmentProfileDto()]),
      ],
    );

    expect(
      message.logSummary,
      'SFERA_G2B_ReplyMessage{messageId: msg-1, correlationId: corr-1, '
      'content: G2B_ReplyPayload[JourneyProfile, SegmentProfile]}',
    );
  });

  test('logSummary_whenNoCorrelationId_thenLogsNull', () {
    final message = SferaG2bReplyMessageDto(
      children: [
        MessageHeaderDto(attributes: {'message_ID': 'msg-1'}),
      ],
    );

    expect(message.logSummary, 'SFERA_G2B_ReplyMessage{messageId: msg-1, correlationId: null, content: }');
  });
}
