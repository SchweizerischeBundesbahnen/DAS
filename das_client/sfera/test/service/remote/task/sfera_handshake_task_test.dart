import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/handshake_task.dart';
import 'package:sfera/src/data/dto/enums/das_driving_mode_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

import 'sfera_handshake_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaService>(),
  MockSpec<MqttService>(),
])
void main() {
  late MockSferaService sferaService;
  late MockMqttService mqttService;
  late OtnIdDto otnId;
  Fimber.plantTree(DebugTree());

  setUp(() {
    sferaService = MockSferaService();
    when(sferaService.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    otnId = OtnIdDto.create('1085', '719', DateTime.now());
  });

  test('Test handshake successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaService: sferaService,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: DasDrivingModeDto.readOnly,
    );

    await handshakeTask.execute((task, data) {
      expect(task, handshakeTask);
      expect(data, isNull);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test handshake reject', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaService: sferaService,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: DasDrivingModeDto.readOnly,
    );

    await handshakeTask.execute((task, data) {
      fail('Task should not be sucessful');
    }, (task, errorCode) {
      expect(errorCode, SferaError.handshakeRejected);
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test handshake ignore other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaService: sferaService,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: DasDrivingModeDto.readOnly,
    );

    await handshakeTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessageDto>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test handshake timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
      sferaService: sferaService,
      mqttService: mqttService,
      otnId: otnId,
      dasDrivingMode: DasDrivingModeDto.readOnly,
      timeout: const Duration(seconds: 1),
    );

    var timeoutReached = false;
    await handshakeTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      expect(errorCode, SferaError.requestTimeout);
      timeoutReached = true;
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timeoutReached, true);
  });
}
