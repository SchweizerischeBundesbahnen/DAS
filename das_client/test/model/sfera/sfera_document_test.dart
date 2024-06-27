import 'dart:io';

import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    Fimber.plantTree(DebugTree());
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

  });
}
