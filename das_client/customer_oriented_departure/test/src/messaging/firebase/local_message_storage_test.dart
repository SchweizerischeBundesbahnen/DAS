import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/local_message_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalMessageStorage testee;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    testee = LocalMessageStorage();
  });

  test('addMessage_whenMessageAdded_thenCanBeLoadedAgain', () async {
    // GIVEN
    final message = BaseMessageDto(messageId: 'message-1');

    // ACT
    await testee.addMessage(message);
    final storedMessages = await testee.getLatestMessages();

    // VERIFY
    expect(storedMessages, hasLength(1));
    expect(storedMessages.single, isA<BaseMessageDto>());
    expect(storedMessages.single.messageId, 'message-1');
  });

  test('getLatestMessages_whenMessagesAdded_thenReturnsOrdered', () async {
    // GIVEN
    final message1 = BaseMessageDto(messageId: 'message-1');
    await testee.addMessage(message1);
    final message2 = BaseMessageDto(messageId: 'message-2');
    await testee.addMessage(message2);
    final message3 = TrainStatusMessageDto(
      messageId: 'message-3',
      zugnr: 'RE1',
      bp: 'Bern',
      status: 'READY',
    );
    await testee.addMessage(message3);

    // ACT
    final storedMessages = await testee.getLatestMessages();

    // VERIFY
    expect(storedMessages, hasLength(3));

    expect(storedMessages[0], isA<BaseMessageDto>());
    expect(storedMessages[0].messageId, 'message-1');

    expect(storedMessages[1], isA<BaseMessageDto>());
    expect(storedMessages[1].messageId, 'message-2');

    expect(storedMessages[2], isA<TrainStatusMessageDto>());
    final trainStatusMessage = storedMessages[2] as TrainStatusMessageDto;
    expect(trainStatusMessage.messageId, 'message-3');
    expect(trainStatusMessage.zugnr, 'RE1');
    expect(trainStatusMessage.bp, 'Bern');
    expect(trainStatusMessage.status, 'READY');
  });

  test('clear_whenMessagesStored_thenRemovesAllMessages', () async {
    // GIVEN
    await testee.addMessage(BaseMessageDto(messageId: 'message-1'));

    // ACT
    await testee.clear();
    final storedMessages = await testee.getLatestMessages();

    // VERIFY
    expect(storedMessages, isEmpty);
  });
}
