import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/handshake_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/model/otn_id.dart';

import 'sfera_handshake_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRepo>(),
  MockSpec<MqttService>(),
])
void main() {
  late MockSferaRepo mockSferaRepo;
  late MockMqttService mqttService;
  late OtnId otnId;

  setUp(() {
    mockSferaRepo = MockSferaRepo();
    when(mockSferaRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenHandshakeSuccessful_thenReturnsTrue', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: .readOnly,
    );

    await handshakeTask.execute(
      (task, data) {
        expect(task, handshakeTask);
        expect(data, isNull);
      },
      (task, error) => fail('Task failed with error $error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('execute_whenHandshakeRejected_thenReturnsTrueWithHandshakeRejectedError', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: .readOnly,
    );

    await handshakeTask.execute(
      (task, data) => fail('Task should not be sucessful'),
      (task, error) => expect(error, isA<HandshakeRejected>()),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('execute_whenCalledWithOtherMessage_thenIsIgnored', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: .readOnly,
    );

    await handshakeTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('execute_whenHandshakeIsTimedOut_thenFailsWithRequestTimeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: .readOnly,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await handshakeTask.execute(
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

  test('execute_whenHandshakeFailsWithError_thenFailsWithProtocolError', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaRepo: mockSferaRepo,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: .readOnly,
      timeout: const Duration(seconds: 1),
    );

    await handshakeTask.execute(
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

    final file = File('test_resources/SFERA_G2B_ReplyMessage_Error.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });
}
