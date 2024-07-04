import 'dart:io';

import 'package:das_client/model/sfera/das_operating_modes_supported.dart';
import 'package:das_client/model/sfera/enums/das_architecture.dart';
import 'package:das_client/model/sfera/enums/das_connectivity.dart';
import 'package:das_client/model/sfera/enums/das_driving_mode.dart';
import 'package:das_client/model/sfera/enums/related_train_request_type.dart';
import 'package:das_client/model/sfera/handshake_request.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/sfera_b2g_request_message.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    Fimber.plantTree(DebugTree());
  });

  test('Test child elements are unmodifiable', () async {
    final file = new File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    var parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.children.add(SferaXmlElement(type: "dummy")), throwsA(isA<UnsupportedError>()));
  });

  test('Test attributes are unmodifiable', () async {
    final file = new File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    var parsedMessage = SferaReplyParser.parse(file.readAsStringSync());

    expect(() => parsedMessage.attributes["dummy"] = "dummy", throwsA(isA<UnsupportedError>()));
  });

  test('Test SferaReplyParser with SFERA_G2B_Reply_JP_request_9232.xml', () async {
    final file = new File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');

    var sferaG2bReplyMessage = SferaReplyParser.parse(file.readAsStringSync());
    expect(sferaG2bReplyMessage, isA<SferaG2bReplyMessage>());
    expect(sferaG2bReplyMessage.type, SferaG2bReplyMessage.elementType);
    expect(sferaG2bReplyMessage.validate(), true);

    expect(sferaG2bReplyMessage.messageHeader.sender, "0088");
    expect(sferaG2bReplyMessage.messageHeader.recipient, "1088");

    expect(sferaG2bReplyMessage.payload.journeyProfiles, hasLength(1));
    expect(sferaG2bReplyMessage.payload.journeyProfiles.first.segmentProfilesLists, hasLength(23));

    expect(sferaG2bReplyMessage.payload.segmentProfiles, hasLength(23));
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points, isNotNull);
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.zone, isNotNull);
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.zone!.imId, "0088");

    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.timingPoints, hasLength(3));
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.timingPoints.first.id, "1837");
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.timingPoints.first.location, "0");
    expect(
        sferaG2bReplyMessage.payload.segmentProfiles.first.points!.timingPoints.first.names.first.name, "MEER-GRENS");

    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.signals, hasLength(9));
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.signals.first.id.physicalId, "102346");
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.signals.first.id.location, "843");

    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.balise, hasLength(3));
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.balise.first.location, "0");
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.balise.first.position.latitude, "51.48591");
    expect(sferaG2bReplyMessage.payload.segmentProfiles.first.points!.balise.first.position.longitude, "4.73459");
  });

  test('Test Sfera HandshakeRequest generation', () async {
    var handshakeRequest = HandshakeRequest.create([
      DasOperatingModesSupported.create(
          DASDrivingMode.goa1, DASArchitecture.boardAdviceCalculation, DASConnectivity.connected),
      DasOperatingModesSupported.create(
          DASDrivingMode.goa1, DASArchitecture.boardAdviceCalculation, DASConnectivity.standalone)
    ], relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndOrRelatedTrains, statusReportsEnabled: true);

    var messageHeader = MessageHeader.create("a24e63c3-ab2e-4102-9a10-ba058dec5efe", "2019-09-26T20:07:36Z", "DAS", "TMS", "1084", "0084");

    var sferaB2gRequestMessage = SferaB2gRequestMessage.create(messageHeader, handshakeRequest: handshakeRequest);
    expect(sferaB2gRequestMessage.validate(), true);

    var xmlDocument = sferaB2gRequestMessage.buildDocument();
    var sferaB2gRequestMessageString = xmlDocument.toXmlString(pretty: true, newLine: "\r\n", indent: "\t");

    final file = new File('test_resources/SFERA_B2G_RequestMessage_handshake.xml');
    final xmlFileString = file.readAsStringSync();
    expect(sferaB2gRequestMessageString, xmlFileString);
  });
}
