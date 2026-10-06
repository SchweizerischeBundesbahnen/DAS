import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_related_train_information_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/model/otn_id.dart';

import 'sfera_request_related_train_information_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRepository>(),
  MockSpec<MqttService>(),
])
void main() {
  late MockSferaRepository mockSferaRepo;
  late MockMqttService mqttService;
  late OtnId otnId;

  setUp(() {
    mockSferaRepo = MockSferaRepository();
    when(mockSferaRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenRequestRelatedTrainInformationSuccessful_thenReturnsTrue', () async {
    // GIVEN
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    final replyMessage = _parseReplyMessage('test_resources/SFERA_G2B_Reply_RTI_request.xml');
    final rtiTask = RequestRelatedTrainInformationTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      otnId: otnId,
    );

    // WHEN
    await rtiTask.execute(
      (task, data) {
        expect(task, rtiTask);
        expect(data, isA<RelatedTrainInformationDto>());
        expect(data, replyMessage.payload!.relatedTrainInformation);
      },
      (task, error) => fail('Task failed with error $error'),
    );
    final result = await rtiTask.handleMessage(replyMessage);

    // THEN
    verify(mqttService.publishMessage(any, any, any)).called(1);
    expect(result, true);
  });

  test('execute_whenRequestRelatedTrainInformationWithOtherMessage_thenIsIgnored', () async {
    // GIVEN
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    final rtiTask = RequestRelatedTrainInformationTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      otnId: otnId,
    );

    // WHEN
    await rtiTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );
    final handshakeReply = _parseReplyMessage('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final result = await rtiTask.handleMessage(handshakeReply);

    // THEN
    expect(result, false);
  });

  test('execute_whenRequestRelatedTrainInformationIsTimedOut_thenFailsWithRequestTimeout', () async {
    // GIVEN
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final rtiTask = RequestRelatedTrainInformationTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      otnId: otnId,
      timeout: const Duration(seconds: 1),
    );

    // WHEN
    var timeoutReached = false;
    await rtiTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(error, isA<RequestTimeout>());
        timeoutReached = true;
      },
    );
    await Future.delayed(const Duration(milliseconds: 1200));

    // THEN
    verify(mqttService.publishMessage(any, any, any)).called(1);
    expect(timeoutReached, true);
  });

  test('execute_whenRequestRelatedTrainInformationFailsWithError_thenFailsWithProtocolError', () async {
    // GIVEN
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    final rtiTask = RequestRelatedTrainInformationTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      otnId: otnId,
    );

    // WHEN
    await rtiTask.execute(
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
    final errorReply = _parseReplyMessage('test_resources/SFERA_G2B_ReplyMessage_Error.xml');
    final result = await rtiTask.handleMessage(errorReply);

    // THEN
    verify(mqttService.publishMessage(any, any, any)).called(1);
    expect(result, false);
  });
}

SferaG2bReplyMessageDto _parseReplyMessage(String path) =>
    SferaReplyParser.parse<SferaG2bReplyMessageDto>(File(path).readAsStringSync());
