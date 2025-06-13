import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_train_characteristics_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';

import 'sfera_request_train_characteristic_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRemoteRepo>(),
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaRemoteRepo sferaService;
  late MockMqttService mqttService;
  late MockSferaLocalDatabaseService sferaRepository;
  late OtnId otnId;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS Tests', isDebugMode: true).call);

  setUp(() {
    sferaService = MockSferaRemoteRepo();
    when(sferaService.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaRepository = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('Test TC request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaService: sferaService,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
      (task, data) {
        expect(task, tcTask);
        expect(data, sferaG2bReplyMessage.payload!.trainCharacteristics);
      },
      (task, errorCode) {
        fail('Task failed with error code $errorCode');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test TC request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaService: sferaService,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
      (task, data) {
        expect(task, tcTask);
      },
      (task, errorCode) {
        fail('Task failed with error code $errorCode');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveTrainCharacteristics(any)).called(1);
  });

  test('Test TC request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaService: sferaService,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
      (task, data) {
        fail('Test should not call success');
      },
      (task, errorCode) {
        fail('Test should not call error');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final handShakefile = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final handshakeSferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      handShakefile.readAsStringSync(),
    );
    final result = await tcTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request segment profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaService: sferaService,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await tcTask.execute(
      (task, data) {
        fail('Test should not call success');
      },
      (task, errorCode) {
        expect(errorCode, SferaError.requestTimeout);
        timeoutReached = true;
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timeoutReached, true);
  });
}
