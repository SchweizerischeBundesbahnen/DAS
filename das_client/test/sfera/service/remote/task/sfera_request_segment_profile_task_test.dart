import 'dart:io';

import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/service/remote/task/request_segment_profiles_task.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sfera_request_journey_profile_task_test.mocks.dart';

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

  test('Test SP request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await segmentTask.execute((task, data) {
      expect(task, segmentTask);
      expect(data, sferaG2bReplyMessage.payload!.segmentProfiles);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test SP request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await segmentTask.execute((task, data) {
      expect(task, segmentTask);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verify(sferaRepository.saveSegmentProfile(any)).called(23);
  });

  test('Test SP request fail on invalid SP', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_sp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await segmentTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(task, segmentTask);
      expect(errorCode, ErrorCode.sferaInvalid);
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verify(sferaRepository.saveSegmentProfile(any)).called(22);
  });

  test('Test SP request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
        mqttService: mqttService,
        sferaDatabaseRepository: sferaRepository,
        otnId: otnId,
        journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first);

    await segmentTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final handShakefile = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final handshakeSferaG2bReplyMessage =
        SferaReplyParser.parse<SferaG2bReplyMessage>(handShakefile.readAsStringSync());
    final result = await segmentTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request segment profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final spTask = RequestSegmentProfilesTask(
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await spTask.execute((task, data) {
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
