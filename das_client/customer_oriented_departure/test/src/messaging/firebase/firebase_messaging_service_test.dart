import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/firebase_messaging_service.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/local_message_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'firebase_messaging_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseMessaging>(),
  MockSpec<LocalMessageStorage>(),
])
void main() {
  group('FirebaseMessagingService', () {
    late FirebaseMessagingService testee;
    late MockFirebaseMessaging mockFirebaseMessaging;
    late MockLocalMessageStorage mockLocalMessageStorage;
    late BehaviorSubject<String> rxToken;

    const initialToken = 'initial-token';

    setUp(() {
      mockFirebaseMessaging = MockFirebaseMessaging();
      mockLocalMessageStorage = MockLocalMessageStorage();
      rxToken = BehaviorSubject<String>();

      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => initialToken);
      when(mockFirebaseMessaging.onTokenRefresh).thenAnswer((_) => rxToken.stream);
      when(mockLocalMessageStorage.clear()).thenAnswer((_) async {});
      when(mockLocalMessageStorage.getLatestMessages()).thenAnswer((_) async => []);

      testee = FirebaseMessagingService(
        firebaseMessaging: mockFirebaseMessaging,
        localMessageStorage: mockLocalMessageStorage,
        handleBackgroundMessages: false,
      );
    });

    tearDown(() async {
      testee.dispose();
      await rxToken.close();
    });

    test('initialize_whenCreated_thenClearsStorageAndReadsInitialToken', () async {
      // ACT
      await _drainAsyncWork();

      // VERIFY
      verify(mockLocalMessageStorage.clear()).called(1);
      verify(mockFirebaseMessaging.getToken()).called(1);
      expect(testee.tokenValue, initialToken);
    });

    test('token_whenTokenRefreshed_thenEmitsRefreshedToken', () async {
      // GIVEN
      await _drainAsyncWork();
      final emittedTokens = <String?>[];
      final subscription = testee.token.listen(emittedTokens.add);

      // ACT
      rxToken.add('refreshed-token');
      await _drainAsyncWork();

      // VERIFY
      expect(testee.tokenValue, 'refreshed-token');
      expect(emittedTokens, contains('refreshed-token'));
      await subscription.cancel();
    });

    test('replayMessages_whenLocalMessagesExist_thenEmitsMessagesAndClearsStorage', () async {
      // GIVEN
      await _drainAsyncWork();
      clearInteractions(mockLocalMessageStorage);

      final storedMessages = <BaseMessageDto>[
        BaseMessageDto(messageId: 'message-1'),
        TrainStatusMessageDto(
          messageId: 'message-2',
          zugnr: '1234',
          bp: 'Bern',
          status: 'call',
        ),
      ];
      when(mockLocalMessageStorage.getLatestMessages()).thenAnswer((_) async => storedMessages);

      final emittedMessages = <BaseMessageDto>[];
      final subscription = testee.message.listen(emittedMessages.add);

      // ACT
      await testee.replayMessages();
      await _drainAsyncWork();

      // VERIFY
      verify(mockLocalMessageStorage.getLatestMessages()).called(1);
      verify(mockLocalMessageStorage.clear()).called(1);
      expect(emittedMessages, hasLength(2));
      expect(emittedMessages[0].messageId, 'message-1');
      expect(emittedMessages[1], isA<TrainStatusMessageDto>());
      expect(emittedMessages[1].messageId, 'message-2');
      await subscription.cancel();
    });
  });
}

Future<void> _drainAsyncWork([int cycles = 5]) async {
  for (var i = 0; i < cycles; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
