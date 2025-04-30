import 'dart:io';

import 'package:app/mqtt/mqtt_component.dart';
import 'package:app/sfera/sfera_component.dart';
import 'package:app/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:app/sfera/src/service/remote/task/request_train_characteristics_task.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sfera_request_train_characteristic_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaDatabaseRepository>(),
])
void main() {
  late MockMqttService mqttService;
  late MockSferaDatabaseRepository sferaRepository;
  late OtnId otnId;
  Fimber.plantTree(DebugTree());

  setUp(() {
    mqttService = MockMqttService();
    sferaRepository = MockSferaDatabaseRepository();
    otnId = OtnId.create('1085', '719', DateTime.now());
  });

  test('Test TC request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await tcTask.execute((task, data) {
      expect(task, tcTask);
      expect(data, sferaG2bReplyMessage.payload!.trainCharacteristics);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test TC request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await tcTask.execute((task, data) {
      expect(task, tcTask);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveTrainCharacteristics(any)).called(1);
  });

  test('Test TC request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await tcTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final handShakefile = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final handshakeSferaG2bReplyMessage =
        SferaReplyParser.parse<SferaG2bReplyMessage>(handShakefile.readAsStringSync());
    final result = await tcTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request segment profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await tcTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(errorCode, ErrorCode.sferaRequestTimeout);
      timeoutReached = true;
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timeoutReached, true);
  });
}
