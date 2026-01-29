import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_journey_profile_task.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
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
  late MockSferaLocalDatabaseService sferaRepository;
  late OtnId otnId;

  setUp(() {
    sferaRemoteRepo = MockSferaRemoteRepo();
    when(sferaRemoteRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaRepository = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenRequestJourneyProfileSuccessful_thenReturnsJourneyProfiles', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) {
        expect(task, journeyTask);
        expect(data!.whereType<JourneyProfileDto>().first, sferaG2bReplyMessage.payload!.journeyProfiles.first);
      },
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('execute_whenRequestJourneyProfileSuccessful_thenSavesToSferaRepository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) => expect(task, journeyTask),
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveJourneyProfile(any)).called(1);
    verify(sferaRepository.saveSegmentProfile(any)).called(23);
  });

  test('execute_whenRequestJourneyProfileWithInvalidJP_thenFailsWithJpUnavailable', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_jp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(task, journeyTask);
        expect(error, isA<JpUnavailable>());
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verifyNever(sferaRepository.saveSegmentProfile(any));
  });

  test('execute_whenRequestJourneyProfileUnavailableJP_thenFailsWithJpUnavailable', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232_unavailable_jp.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(task, journeyTask);
        expect(error, isA<JpUnavailable>());
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verifyNever(sferaRepository.saveJourneyProfile(any));
    verifyNever(sferaRepository.saveSegmentProfile(any));
  });

  test('execute_whenRequestJourneyProfileWithOtherMessage_thenIsIgnored', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('execute_whenRequestJourneyProfileIsTimedOut_thenFailsWithRequestTimeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await journeyTask.execute(
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

  test('execute_whenRequestJourneyProfileSuccessful_thenSavesTCToSferaRepository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
      (task, data) => expect(task, journeyTask),
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveJourneyProfile(any)).called(1);
    verify(sferaRepository.saveTrainCharacteristics(any)).called(1);
  });

  test('execute_whenRequestJourneyProfileFailsWithError_thenFailsWithProtocolError', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final journeyTask = RequestJourneyProfileTask(
      sferaService: sferaRemoteRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
    );

    await journeyTask.execute(
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

    final result = await journeyTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });
}
