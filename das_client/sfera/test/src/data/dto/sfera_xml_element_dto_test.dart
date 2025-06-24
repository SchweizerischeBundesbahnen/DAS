import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:sfera/src/data/dto/das_operating_modes_supported_dto.dart';
import 'package:sfera/src/data/dto/enums/das_architecture_dto.dart';
import 'package:sfera/src/data/dto/enums/das_connectivity_dto.dart';
import 'package:sfera/src/data/dto/enums/das_driving_mode_dto.dart';
import 'package:sfera/src/data/dto/enums/related_train_request_type_dto.dart';
import 'package:sfera/src/data/dto/handshake_request_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_request_message_dto.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS Tests', isDebugMode: true).call);

  test('Test Sfera HandshakeRequest generation', () async {
    final handshakeRequest = HandshakeRequestDto.create(
      [
        DasOperatingModesSupportedDto.create(
          DasDrivingModeDto.goa1,
          DasArchitectureDto.boardAdviceCalculation,
          DasConnectivityDto.connected,
        ),
        DasOperatingModesSupportedDto.create(
          DasDrivingModeDto.goa1,
          DasArchitectureDto.boardAdviceCalculation,
          DasConnectivityDto.standalone,
        ),
      ],
      relatedTrainRequestType: RelatedTrainRequestTypeDto.ownTrainAndOrRelatedTrains,
      statusReportsEnabled: true,
    );

    final messageHeader = MessageHeaderDto.create(
      'a24e63c3-ab2e-4102-9a10-ba058dec5efe',
      '2019-09-26T20:07:36Z',
      'DAS',
      'TMS',
      '1084',
      '0084',
    );

    final sferaB2gRequestMessage = SferaB2gRequestMessageDto.create(messageHeader, handshakeRequest: handshakeRequest);
    expect(sferaB2gRequestMessage.validate(), true);

    final xmlDocument = sferaB2gRequestMessage.buildDocument();
    final sferaB2gRequestMessageString = xmlDocument.toXmlString(pretty: true, newLine: '\r\n', indent: '\t');

    final file = File('test_resources/SFERA_B2G_RequestMessage_handshake.xml');
    var xmlFileString = file.readAsStringSync();
    xmlFileString = xmlFileString.replaceAll(RegExp(r'<SFERA_B2G_RequestMessage.*>'), '<SFERA_B2G_RequestMessage>');
    expect(sferaB2gRequestMessageString.normalize, xmlFileString.normalize);
  });
}

extension _XmlExtension on String {
  String get normalize => replaceAll(RegExp(r'\s+'), '');
}
