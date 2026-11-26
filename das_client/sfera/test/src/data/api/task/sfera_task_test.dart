import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/api/task/sfera_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

void main() {
  for (final scenario in [
    (name: 'NoRequestMessageId', requestMessageId: null, correlationId: 'request-id', isCancelled: false),
    (name: 'NoRequestOrCorrelationId', requestMessageId: null, correlationId: null, isCancelled: false),
    (name: 'NoCorrelationId', requestMessageId: 'request-id', correlationId: null, isCancelled: false),
    (name: 'DifferentCorrelationId', requestMessageId: 'request-id', correlationId: 'other-id', isCancelled: false),
    (name: 'Cancelled', requestMessageId: 'request-id', correlationId: 'request-id', isCancelled: true),
  ]) {
    test('handleMessage_when${scenario.name}_thenIgnoresReply', () async {
      // GIVEN
      final task = _TestSferaTask()..requestMessageId = scenario.requestMessageId;
      final reply = SferaG2bReplyMessageDto(
        children: [
          MessageHeaderDto(
            attributes: {'correlation_ID': ?scenario.correlationId},
          ),
        ],
      );
      if (scenario.isCancelled) {
        task.cancel();
      }

      // WHEN
      final result = await task.handleMessage(reply);

      // THEN
      expect(task.isCancelled, scenario.isCancelled);
      expect(result, false);
      expect(task.handledReplies, isEmpty);
    });
  }

  for (final handlerResult in [true, false]) {
    test('handleMessage_whenCorrelationIdMatchesAndHandlerReturns${handlerResult}_thenReturnsHandlerResult', () async {
      // GIVEN
      final task = _TestSferaTask(handlerResult: handlerResult)..requestMessageId = 'request-id';
      final reply = SferaG2bReplyMessageDto(
        children: [
          MessageHeaderDto(attributes: {'correlation_ID': 'request-id'}),
        ],
      );

      // WHEN
      final result = await task.handleMessage(reply);

      // THEN
      expect(task.isCancelled, false);
      expect(result, handlerResult);
      expect(task.handledReplies, [same(reply)]);
    });
  }

  test('handleMessage_whenRequestMessageIdChanges_thenOnlyHandlesLatestRequestReply', () async {
    // GIVEN
    final task = _TestSferaTask()..requestMessageId = 'old-request-id';
    final oldReply = SferaG2bReplyMessageDto(
      children: [
        MessageHeaderDto(attributes: {'correlation_ID': 'old-request-id'}),
      ],
    );
    final latestReply = SferaG2bReplyMessageDto(
      children: [
        MessageHeaderDto(attributes: {'correlation_ID': 'latest-request-id'}),
      ],
    );
    task.requestMessageId = 'latest-request-id';

    // WHEN
    final oldResult = await task.handleMessage(oldReply);
    final latestResult = await task.handleMessage(latestReply);

    // THEN
    expect(oldResult, false);
    expect(latestResult, true);
    expect(task.handledReplies, [same(latestReply)]);
  });
}

class _TestSferaTask({this.handlerResult = true}) extends SferaTask<void> {
  final bool handlerResult;
  final handledReplies = <SferaG2bReplyMessageDto>[];

  @override
  Future<void> execute(TaskCompleted<void> onCompleted, TaskFailed onFailed) async {}

  @override
  Future<bool> handleReplyMessage(SferaG2bReplyMessageDto replyMessage) async {
    handledReplies.add(replyMessage);
    return handlerResult;
  }
}
