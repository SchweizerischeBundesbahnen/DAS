import 'dart:io';

import 'package:das_client/sfera/src/model/das_operating_modes_supported.dart';
import 'package:das_client/sfera/src/model/enums/das_architecture.dart';
import 'package:das_client/sfera/src/model/enums/das_connectivity.dart';
import 'package:das_client/sfera/src/model/enums/das_driving_mode.dart';
import 'package:das_client/sfera/src/model/enums/handshake_reject_reason.dart';
import 'package:das_client/sfera/src/model/enums/related_train_request_type.dart';
import 'package:das_client/sfera/src/model/handshake_request.dart';
import 'package:das_client/sfera/src/model/message_header.dart';
import 'package:das_client/sfera/src/model/sfera_b2g_request_message.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/sfera_reply_parser.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Fimber.plantTree(DebugTree());

  test('Test child elements are unmodifiable', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.children.add(SferaXmlElement(type: 'dummy')), throwsA(isA<UnsupportedError>()));
  });

  test('Test attributes are unmodifiable', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.attributes['dummy'] = 'dummy', throwsA(isA<UnsupportedError>()));
  });

  test('Test SferaReplyParser with SFERA_G2B_Reply_JP_request_9232.xml', () async {
    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessage>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessage.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0088');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1088');

    expect(sferaG2bReplyMessage.payload, isNotNull);
    final payload = sferaG2bReplyMessage.payload!;

    expect(payload.journeyProfiles, hasLength(1));
    expect(payload.journeyProfiles.first.segmentProfilesLists, hasLength(23));

    expect(payload.segmentProfiles, hasLength(23));
    expect(payload.segmentProfiles.first.points, isNotNull);
    expect(payload.segmentProfiles.first.zone, isNotNull);
    expect(payload.segmentProfiles.first.zone!.imId, '0088');

    final spPoint = payload.segmentProfiles.first.points.first;

    expect(spPoint.timingPoints, hasLength(3));
    expect(spPoint.timingPoints.first.id, '1837');
    expect(spPoint.timingPoints.first.location, 0);
    expect(spPoint.timingPoints.first.names.first.name, 'MEER-GRENS');

    expect(spPoint.signals, hasLength(9));
    expect(spPoint.signals.first.id.physicalId, '102346');
    expect(spPoint.signals.first.id.location, 843.0);

    expect(spPoint.balise, hasLength(3));
    expect(spPoint.balise.first.location, '0');
    expect(spPoint.balise.first.position.latitude, '51.48591');
    expect(spPoint.balise.first.position.longitude, '4.73459');
  });

  test('Test Sfera HandshakeRequest generation', () async {
    final handshakeRequest = HandshakeRequest.create([
      DasOperatingModesSupported.create(
          DasDrivingMode.goa1, DasArchitecture.boardAdviceCalculation, DasConnectivity.connected),
      DasOperatingModesSupported.create(
          DasDrivingMode.goa1, DasArchitecture.boardAdviceCalculation, DasConnectivity.standalone)
    ], relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndOrRelatedTrains, statusReportsEnabled: true);

    final messageHeader = MessageHeader.create(
        'a24e63c3-ab2e-4102-9a10-ba058dec5efe', '2019-09-26T20:07:36Z', 'DAS', 'TMS', '1084', '0084');

    final sferaB2gRequestMessage = SferaB2gRequestMessage.create(messageHeader, handshakeRequest: handshakeRequest);
    expect(sferaB2gRequestMessage.validate(), true);

    final xmlDocument = sferaB2gRequestMessage.buildDocument();
    final sferaB2gRequestMessageString = xmlDocument.toXmlString(pretty: true, newLine: '\r\n', indent: '\t');

    final file = File('test_resources/SFERA_B2G_RequestMessage_handshake.xml');
    final xmlFileString = file.readAsStringSync();
    expect(sferaB2gRequestMessageString, xmlFileString);
  });

  test('Test SferaReplyParser with SFERA_G2B_ReplyMessage_handshake.xml', () async {
    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessage>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessage.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0084');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1084');

    expect(sferaG2bReplyMessage.handshakeAcknowledgement, isNotNull);
    final handshakeAcknowledgement = sferaG2bReplyMessage.handshakeAcknowledgement!;

    expect(handshakeAcknowledgement.operationModeSelected.architecture, DasArchitecture.boardAdviceCalculation);
    expect(handshakeAcknowledgement.operationModeSelected.connectivity, DasConnectivity.connected);
  });

  test('Test SferaReplyParser with SFERA_G2B_ReplyMessage_handshake_rejected.xml', () async {
    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');

    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessage>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessage.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, '0084');
    expect(sferaG2bReplyMessage.messageHeader.recipient, '1084');

    expect(sferaG2bReplyMessage.handshakeAcknowledgement, isNull);
    expect(sferaG2bReplyMessage.handshakeReject, isNotNull);
    final handshakeReject = sferaG2bReplyMessage.handshakeReject!;

    expect(handshakeReject.handshakeRejectReason, HandshakeRejectReason.connectivityNotSupported);
  });
}
