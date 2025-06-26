import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_segment_profiles_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

import 'sfera_request_journey_profile_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRemoteRepo>(),
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaRemoteRepo sferaRemoteRepo;
  late MockMqttService mqttService;
  late MockSferaLocalDatabaseService sferaLocalService;
  late OtnId otnId;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS Tests', isDebugMode: true).call);

  setUp(() {
    sferaRemoteRepo = MockSferaRemoteRepo();
    when(sferaRemoteRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaLocalService = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('Test SP request successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) {
        expect(task, segmentTask);
        expect(data, sferaG2bReplyMessage.payload!.segmentProfiles);
      },
      (task, errorCode) {
        fail('Task failed with error code $errorCode');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test SP request saves to sfera repository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) {
        expect(task, segmentTask);
      },
      (task, errorCode) {
        fail('Task failed with error code $errorCode');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaLocalService.saveJourneyProfile(any));
    verify(sferaLocalService.saveSegmentProfile(any)).called(23);
  });

  test('Test SP request fail on invalid SP', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_sp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) {
        fail('Test should not call success');
      },
      (task, errorCode) {
        expect(task, segmentTask);
        expect(errorCode, SferaError.invalid);
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaLocalService.saveJourneyProfile(any));
    verify(sferaLocalService.saveSegmentProfile(any)).called(22);
  });

  test('Test SP request ignores other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
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
    final result = await segmentTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test request segment profile timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final spTask = RequestSegmentProfilesTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await spTask.execute(
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
