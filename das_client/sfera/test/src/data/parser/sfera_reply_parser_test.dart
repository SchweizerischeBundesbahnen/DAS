import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/enums/das_architecture_dto.dart';
import 'package:sfera/src/data/dto/enums/das_connectivity_dto.dart';
import 'package:sfera/src/data/dto/enums/handshake_reject_reason_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

void main() {
  Fimber.plantTree(DebugTree());

  test('Test child elements are unmodifiable', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.children.add(SferaXmlElementDto(type: 'dummy')), throwsA(isA<UnsupportedError>()));
  });

  test('Test attributes are unmodifiable', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.attributes['dummy'] = 'dummy', throwsA(isA<UnsupportedError>()));
  });

  test('Test SferaReplyParser with SFERA_G2B_Reply_JP_request_9232.xml', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessageDto>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessageDto.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0088');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1088');

    expect(sferaG2bReplyMessage.payload, isNotNull);
    final payload = sferaG2bReplyMessage.payload!;

    expect(payload.journeyProfiles, hasLength(1));
    expect(payload.journeyProfiles.first.segmentProfileReferences, hasLength(23));

    expect(payload.segmentProfiles, hasLength(23));
    expect(payload.segmentProfiles.first.points, isNotNull);
    expect(payload.segmentProfiles.first.zone, isNotNull);
    expect(payload.segmentProfiles.first.zone!.imId, '0088');

    final spPoint = payload.segmentProfiles.first.points!;

    expect(spPoint.timingPoints, hasLength(3));
    expect(spPoint.timingPoints.first.id, '1837');
    expect(spPoint.timingPoints.first.location, 0);
    expect(spPoint.timingPoints.first.names.first.name, 'MEER-GRENS');

    expect(spPoint.signals, hasLength(9));
    expect(spPoint.signals.first.id.physicalId, '102346');
    expect(spPoint.signals.first.id.location, 843.0);

    expect(spPoint.virtualBalise, hasLength(3));
    expect(spPoint.virtualBalise.first.location, '0');
    expect(spPoint.virtualBalise.first.position.latitude, '51.48591');
    expect(spPoint.virtualBalise.first.position.longitude, '4.73459');
  });

  test('Test SferaReplyParser with SFERA_G2B_ReplyMessage_handshake.xml', () async {
    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessageDto>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessageDto.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0084');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1084');

    expect(sferaG2bReplyMessage.handshakeAcknowledgement, isNotNull);
    final handshakeAcknowledgement = sferaG2bReplyMessage.handshakeAcknowledgement!;

    expect(handshakeAcknowledgement.operationModeSelected.architecture, DasArchitectureDto.boardAdviceCalculation);
    expect(handshakeAcknowledgement.operationModeSelected.connectivity, DasConnectivityDto.connected);
  });

  test('Test SferaReplyParser with SFERA_G2B_ReplyMessage_handshake_rejected.xml', () async {
    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessageDto>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessageDto.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0084');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1084');

    expect(sferaG2bReplyMessage.handshakeAcknowledgement, isNull);
    expect(sferaG2bReplyMessage.handshakeReject, isNotNull);
    final handshakeReject = sferaG2bReplyMessage.handshakeReject!;

    expect(handshakeReject.handshakeRejectReason, HandshakeRejectReasonDto.connectivityNotSupported);
  });
}
