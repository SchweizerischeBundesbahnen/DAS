import 'dart:io';

import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/task/request_journey_profile_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sfera_request_journey_profile_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaRepository>(),
])
void main() {
  late MockMqttService mqttService;
  late MockSferaRepository sferaRepository;
  late OtnId otnId;

  setUp(() {
    Fimber.plantTree(DebugTree());
    mqttService = MockMqttService();
    sferaRepository = MockSferaRepository();
    otnId = OtnId.create("1085", "719", DateTime.now());
  });

  test('Test JP request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    var sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    var journeyTask = RequestJourneyProfileTask(mqttService: mqttService, sferaRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      expect(task, journeyTask);
      expect(data, sferaG2bReplyMessage.payload!.journeyProfiles.first);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    var result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test JP request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    var sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    var journeyTask = RequestJourneyProfileTask(mqttService: mqttService, sferaRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      expect(task, journeyTask);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    var result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveJourneyProfile(any)).called(1);
    verify(sferaRepository.saveSegmentProfile(any)).called(23);
  });

  test('Test JP request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    var journeyTask = RequestJourneyProfileTask(mqttService: mqttService, sferaRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      fail('Test should not call success');
    },(task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    var sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    var result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request journey profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    var journeyTask = RequestJourneyProfileTask(
        mqttService: mqttService, sferaRepository: sferaRepository, otnId: otnId, timeout: const Duration(seconds: 1));

    var timeoutReached = false;
    await journeyTask.execute((task, data) {
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
