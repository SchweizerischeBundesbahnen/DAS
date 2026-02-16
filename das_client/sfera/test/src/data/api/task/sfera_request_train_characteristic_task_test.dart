import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_train_characteristics_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

import 'sfera_request_train_characteristic_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRepository>(),
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaRepository mockSferaRepo;
  late MockMqttService mqttService;
  late MockSferaLocalDatabaseService sferaRepository;
  late OtnId otnId;

  setUp(() {
    mockSferaRepo = MockSferaRepository();
    when(mockSferaRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaRepository = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenRequestTrainCharacteristicsSuccessful_thenReturnsTrue', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaRepo: mockSferaRepo,
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
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('execute_whenRequestTrainCharacteristicsSuccessful_thenSavesToSferaRepository', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
      (task, data) => expect(task, tcTask),
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);

    verify(sferaRepository.saveTrainCharacteristics(any)).called(1);
  });

  test('execute_whenRequestTrainCharacteristicsWithOtherMessage_thenIsIgnored', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final handShakefile = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final handshakeSferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      handShakefile.readAsStringSync(),
    );
    final result = await tcTask.handleMessage(handshakeSferaG2bReplyMessage);
    expect(result, false);
  });

  test('execute_whenRequestTrainCharacteristicsIsTimedOut_thenFailsWithRequestTimeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final file = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: sferaG2bReplyMessage.payload!.journeyProfiles.first,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await tcTask.execute(
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

  test('execute_whenRequestTrainCharacteristicsFailsWithError_thenFailsWithProtocolError', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final tcRequestFile = File('test_resources/SFERA_G2B_Reply_TC_request_T5.xml');
    final tcRequest = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcRequestFile.readAsStringSync());

    final tcTask = RequestTrainCharacteristicsTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      sferaDatabaseRepository: sferaRepository,
      otnId: otnId,
      journeyProfile: tcRequest.payload!.journeyProfiles.first,
    );

    await tcTask.execute(
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
    final result = await tcTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });
}
