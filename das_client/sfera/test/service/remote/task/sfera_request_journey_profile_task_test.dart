import 'dart:io';

import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/src/data/api/task/request_journey_profile_task.dart';

import 'sfera_request_journey_profile_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaDatabaseRepository>(),
])
void main() {
  late MockMqttService mqttService;
  late MockSferaDatabaseRepository sferaRepository;
  late OtnIdDto otnId;
  Fimber.plantTree(DebugTree());

  setUp(() {
    mqttService = MockMqttService();
    sferaRepository = MockSferaDatabaseRepository();
    otnId = OtnIdDto.create('1085', '719', DateTime.now());
  });

  test('Test JP request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      expect(task, journeyTask);
      expect(data!.whereType<JourneyProfileDto>().first, sferaG2bReplyMessage.payload!.journeyProfiles.first);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test JP request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      expect(task, journeyTask);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveJourneyProfile(any)).called(1);
    verify(sferaRepository.saveSegmentProfile(any)).called(23);
  });

  test('Test JP Task fail on JP Invalid', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_jp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(task, journeyTask);
      expect(errorCode, SferaError.jpUnavailable);
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verifyNever(sferaRepository.saveSegmentProfile(any));
  });

  test('Test JP Task fail on JP Unavailable', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_unavailable_jp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(task, journeyTask);
      expect(errorCode, SferaError.jpUnavailable);
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verifyNever(sferaRepository.saveSegmentProfile(any));
  });

  test('Test JP request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request journey profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final journeyTask = RequestJourneyProfileTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        timeout: const Duration(seconds: 1));

    var timeoutReached = false;
    await journeyTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(errorCode, SferaError.requestTimeout);
      timeoutReached = true;
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timeoutReached, true);
  });

  test('Test JP request saves train characteristic to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask =
        RequestJourneyProfileTask(mqttService: mqttService, sferaDatabaseRepository: sferaRepository, otnId: otnId);

    await journeyTask.execute((task, data) {
      expect(task, journeyTask);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveJourneyProfile(any)).called(1);
    verify(sferaRepository.saveTrainCharacteristics(any)).called(1);
  });
}
