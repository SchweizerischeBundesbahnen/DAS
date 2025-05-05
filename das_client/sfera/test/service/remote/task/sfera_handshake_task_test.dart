import 'dart:io';

import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/enums/das_driving_mode.dart';
import 'package:sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:sfera/src/service/remote/task/handshake_task.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sfera_handshake_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
])
void main() {
  late MockMqttService mqttService;
  late OtnId otnId;
  Fimber.plantTree(DebugTree());

  setUp(() {
    mqttService = MockMqttService();
    otnId = OtnId.create('1085', '719', DateTime.now());
  });

  test('Test handshake successful', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask =
        HandshakeTask(mqttService: mqttService, otnId: otnId, dasDrivingMode: DasDrivingMode.readOnly);

    await handshakeTask.execute((task, data) {
      expect(task, handshakeTask);
      expect(data, isNull);
    }, (task, errorCode) {
      fail('Task failed with error code $errorCode');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test handshake reject', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask =
        HandshakeTask(mqttService: mqttService, otnId: otnId, dasDrivingMode: DasDrivingMode.readOnly);

    await handshakeTask.execute((task, data) {
      fail('Task should not be sucessful');
    }, (task, errorCode) {
      expect(errorCode, ErrorCode.sferaHandshakeRejected);
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, true);
  });

  test('Test handshake ignore other messages', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask =
        HandshakeTask(mqttService: mqttService, otnId: otnId, dasDrivingMode: DasDrivingMode.readOnly);

    await handshakeTask.execute((task, data) {
      fail('Test should not call success');
    }, (task, errorCode) {
      fail('Test should not call error');
    });

    verify(mqttService.publishMessage(any, any, any)).called(1);

    final file = File('test_resources/SFERA_G2B_Reply_JP_request_9232.xml');
    final sferaG2bReplyMessage = SferaReplyParser.parse<SferaG2bReplyMessage>(file.readAsStringSync());

    final result = await handshakeTask.handleMessage(sferaG2bReplyMessage);
    expect(result, false);
  });

  test('Test handshake timeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);

    final handshakeTask = HandshakeTask(
        mqttService: mqttService,
        otnId: otnId,
        dasDrivingMode: DasDrivingMode.readOnly,
        timeout: const Duration(seconds: 1));

    var timeoutReached = false;
    await handshakeTask.execute((task, data) {
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
