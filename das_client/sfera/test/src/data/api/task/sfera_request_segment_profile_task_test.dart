import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
  MockSpec<SferaRepo>(),
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaRepo mockSferaRepo;
  late MockMqttService mqttService;
  late MockSferaLocalDatabaseService sferaLocalService;
  late OtnId otnId;

  setUp(() {
    mockSferaRepo = MockSferaRepo();
    when(mockSferaRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaLocalService = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenRequestSegmentProfilesSuccessful_thenReturnsTrue', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
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
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('execute_whenRequestSegmentProfilesSuccessful_thenSavesToSferaRepository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) => expect(task, segmentTask),
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaLocalService.saveJourneyProfile(any));
    verify(sferaLocalService.saveSegmentProfile(any)).called(23);
  });

  test('execute_whenRequestSegmentProfilesWithInvalidSP_thenFailsWithInvalid', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_sp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(task, segmentTask);
        expect(error, isA<Invalid>());
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaLocalService.saveJourneyProfile(any));
    verify(sferaLocalService.saveSegmentProfile(any)).called(22);
  });

  test('execute_whenRequestSegmentProfilesWithOtherMessage_thenIsIgnored', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final handShakefile = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final handshakeSferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      handShakefile.readAsStringSync(),
    );
    final result = await segmentTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('execute_whenRequestSegmentProfilesIsTimedOut_thenFailsWithRequestTimeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final spTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await spTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(error, isA<RequestTimeout>());
        timeoutReached = true;
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timeoutReached, true);
  });

  test('execute_whenRequestSegmentProfilesFailsWithError_thenFailsWithProtocolError', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final jpRequestFile = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final jpRequest = SferaReplyParser.parse<SferaG2bReplyMessageDto>(jpRequestFile.readAsStringSync());

    final segmentTask = RequestSegmentProfilesTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      journeyProfile: jpRequest.payload!.journeyProfiles.first,
    );

    await segmentTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(error, isA<ProtocolErrors>());
        final protocolError = error as ProtocolErrors;
        expect(protocolError.errors, hasLength(1));
        expect(protocolError.errors.first.code, '26');
        expect(
          protocolError.errors.first.additionalInfo?.de,
          'Die Nachricht verwendet eine bereits verwendete message_ID.',
        );
        expect(
          protocolError.errors.first.additionalInfo?.fr,
          'Le message utilise un identifiant message_ID déjà utilisé.',
        );
        expect(protocolError.errors.first.additionalInfo?.it, 'Il messaggio utilizza un message_ID già utilizzato.');
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_Error.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());
    final result = await segmentTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });
}
