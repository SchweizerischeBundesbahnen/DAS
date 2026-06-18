import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/confirm/confirm_request.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/subscribe_request.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:customer_oriented_departure/src/repository/customer_oriented_departure_repository_impl.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'customer_oriented_departure_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CustomerOrientedDepartureApiService>(),
  MockSpec<MessagingService>(),
  MockSpec<ConfirmRequest>(),
  MockSpec<SubscribeRequest>(),
])
void main() {
  late CustomerOrientedDepartureRepositoryImpl testee;
  late MockCustomerOrientedDepartureApiService mockApiService;
  late MockMessagingService mockMessagingService;
  late MockConfirmRequest mockConfirmRequest;
  late MockSubscribeRequest mockSubscribeRequest;
  late MockSubscribeRequest mockUnsubscribeRequest;
  late BehaviorSubject<String?> rxToken;
  late BehaviorSubject<BaseMessageDto> rxMessage;

  const String testPushToken = 'push-token';
  final testJourneyEndTime = DateTime.now();
  final testJourneyEndTimeWithBuffer = testJourneyEndTime.add(CustomerOrientedDepartureRepositoryImpl.expireAtBuffer);

  setUp(() {
    mockApiService = MockCustomerOrientedDepartureApiService();
    mockMessagingService = MockMessagingService();
    mockConfirmRequest = MockConfirmRequest();
    mockSubscribeRequest = MockSubscribeRequest();
    mockUnsubscribeRequest = MockSubscribeRequest();
    rxToken = BehaviorSubject();
    rxMessage = BehaviorSubject();

    when(mockApiService.unsubscribe).thenReturn(mockUnsubscribeRequest);
    when(mockApiService.subscribe).thenReturn(mockSubscribeRequest);
    when(mockApiService.confirm).thenReturn(mockConfirmRequest);

    when(mockMessagingService.tokenValue).thenReturn(testPushToken);
    when(mockMessagingService.token).thenAnswer((_) => rxToken.stream);
    when(mockMessagingService.message).thenAnswer((_) => rxMessage.stream);
    when(mockMessagingService.replayMessages()).thenAnswer((_) => Future.value());

    when(
      mockSubscribeRequest.call(
        evu: anyNamed('evu'),
        trainNumber: anyNamed('trainNumber'),
        pushToken: anyNamed('pushToken'),
        deviceId: anyNamed('deviceId'),
        messageId: anyNamed('messageId'),
        expiresAt: anyNamed('expiresAt'),
        isDriver: anyNamed('isDriver'),
      ),
    ).thenAnswer((_) => Future.value(const SubscribeResponse(headers: {})));

    when(
      mockUnsubscribeRequest.call(
        evu: anyNamed('evu'),
        trainNumber: anyNamed('trainNumber'),
        pushToken: anyNamed('pushToken'),
        deviceId: anyNamed('deviceId'),
        messageId: anyNamed('messageId'),
        expiresAt: anyNamed('expiresAt'),
        isDriver: anyNamed('isDriver'),
      ),
    ).thenAnswer((_) => Future.value(const SubscribeResponse(headers: {})));

    when(
      mockConfirmRequest.call(
        messageId: anyNamed('messageId'),
        deviceId: anyNamed('deviceId'),
      ),
    ).thenAnswer((_) => Future.value(const ConfirmResponse(headers: {})));

    testee = CustomerOrientedDepartureRepositoryImpl(
      apiService: mockApiService,
      messagingService: mockMessagingService,
      deviceId: 'device-1',
    );
  });

  tearDown(() async {
    testee.dispose();
    await rxToken.close();
    await rxMessage.close();
  });

  test('subscribe_whenTokenAvailable_thenCallsRegisterRequest', () async {
    // ACT
    final result = await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

    // VERIFY
    expect(result, isTrue);
    verify(
      mockSubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: testPushToken,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: true,
      ),
    ).called(1);
  });

  test('subscribe_whenNoTokenAvailable_thenReturnsFalseAndSkipsRequest', () async {
    // GIVEN
    when(mockMessagingService.tokenValue).thenReturn(null);

    // ACT
    final result = await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

    // VERIFY
    expect(result, isFalse);
    verifyNever(mockApiService.subscribe);
  });

  test('subscribe_whenJourneyEndTimeIsInThePast_thenUsesDefaultExpireAt', () async {
    // GIVEN
    final pastJourneyEndTime = DateTime.now().subtract(const Duration(hours: 4));
    final defaultExpireAt = DateTime.now().add(CustomerOrientedDepartureRepositoryImpl.defaultExpireAtDuration);

    // ACT
    final result = await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: pastJourneyEndTime,
      isDriver: true,
    );

    // VERIFY
    expect(result, isTrue);
    final verification = verify(
      mockSubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: testPushToken,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: captureAnyNamed('expiresAt'),
        isDriver: true,
      ),
    );
    verification.called(1);

    final capturedExpiresAt = verification.captured.single as DateTime;
    expect(
      capturedExpiresAt.difference(defaultExpireAt).abs().inMilliseconds,
      lessThan(1000),
    );
  });

  test('subscribe_whenPendingSubscriptionExists_thenDeregistersBeforeRegister', () async {
    // GIVEN
    when(mockMessagingService.tokenValue).thenReturn(null);
    await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );
    when(mockMessagingService.tokenValue).thenReturn('new-token');

    // ACT
    final result = await testee.subscribe(
      evu: '1180',
      trainNumber: 'RB77',
      journeyEndTime: testJourneyEndTime,
      isDriver: false,
    );

    // VERIFY
    expect(result, isTrue);
    verifyInOrder([
      mockUnsubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: 'new-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: true,
      ),
      mockSubscribeRequest.call(
        evu: '1180',
        trainNumber: 'RB77',
        pushToken: 'new-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: false,
      ),
    ]);
  });

  test('tokenRefresh_whenPendingSubscriptionExists_thenRegistersWithNewToken', () async {
    // GIVEN
    when(mockMessagingService.tokenValue).thenReturn(null);
    await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

    // ACT
    when(mockMessagingService.tokenValue).thenReturn('refreshed-token');
    rxToken.add('refreshed-token');
    await Future.delayed(Duration.zero);

    // VERIFY
    verifyNever(
      mockSubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: null,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: true,
      ),
    );
    verify(
      mockSubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: 'refreshed-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: true,
      ),
    ).called(1);
  });

  test('subscribe_whenNoConfirmation_thenRetriesWithExponentialBackoff', () {
    fakeAsync((async) {
      // ACT
      testee.subscribe(
        evu: '1080',
        trainNumber: 'RE1234',
        journeyEndTime: testJourneyEndTime,
        isDriver: true,
      );
      async.flushMicrotasks();

      // VERIFY

      final firstCall = verify(
        mockSubscribeRequest.call(
          evu: '1080',
          trainNumber: 'RE1234',
          pushToken: testPushToken,
          deviceId: 'device-1',
          messageId: captureAnyNamed('messageId'),
          expiresAt: testJourneyEndTimeWithBuffer,
          isDriver: true,
        ),
      );
      firstCall.called(1);
      final messageId = firstCall.captured.single as String;

      // 1st retry after 10 seconds
      async.elapse(const Duration(seconds: 10));
      async.flushMicrotasks();
      verify(
        mockSubscribeRequest.call(
          evu: '1080',
          trainNumber: 'RE1234',
          pushToken: testPushToken,
          deviceId: 'device-1',
          messageId: messageId,
          expiresAt: testJourneyEndTimeWithBuffer,
          isDriver: true,
        ),
      ).called(1);

      // 2nd retry after 20 seconds (exponential backoff)
      async.elapse(const Duration(seconds: 20));
      async.flushMicrotasks();
      verify(
        mockSubscribeRequest.call(
          evu: '1080',
          trainNumber: 'RE1234',
          pushToken: testPushToken,
          deviceId: 'device-1',
          messageId: messageId,
          expiresAt: testJourneyEndTimeWithBuffer,
          isDriver: true,
        ),
      ).called(1);

      // check further retries are done without confirmation
      async.elapse(const Duration(hours: 1));
      async.flushMicrotasks();
      final callCount = verify(mockApiService.subscribe).callCount;
      expect(callCount, greaterThan(8));
    });
  });

  test('subscribe_whenConfirmationReceived_thenStopsRetrying', () {
    fakeAsync((async) {
      // ACT
      testee.subscribe(
        evu: '1080',
        trainNumber: 'RE1234',
        journeyEndTime: testJourneyEndTime,
        isDriver: true,
      );
      async.flushMicrotasks();

      // VERIFY

      final initialSubscribeCall = verify(
        mockSubscribeRequest.call(
          evu: '1080',
          trainNumber: 'RE1234',
          pushToken: testPushToken,
          deviceId: 'device-1',
          messageId: captureAnyNamed('messageId'),
          expiresAt: testJourneyEndTimeWithBuffer,
          isDriver: true,
        ),
      );
      initialSubscribeCall.called(1);
      final messageId = initialSubscribeCall.captured.single as String;

      // confirmation message with wrong message id should not cancel retry
      rxMessage.add(BaseMessageDto(messageId: 'random-message-id'));
      async.flushMicrotasks();

      // check first retry that should happen after 10s
      async.elapse(const Duration(seconds: 11));
      async.flushMicrotasks();
      verify(
        mockSubscribeRequest.call(
          evu: '1080',
          trainNumber: 'RE1234',
          pushToken: testPushToken,
          deviceId: 'device-1',
          messageId: messageId,
          expiresAt: testJourneyEndTimeWithBuffer,
          isDriver: true,
        ),
      ).called(1);

      // confirmation message with correct message id should cancel retry
      rxMessage.add(BaseMessageDto(messageId: messageId));
      async.flushMicrotasks();

      // verify that no more retries are tried
      async.elapse(const Duration(minutes: 2));
      async.flushMicrotasks();
      verifyNoMoreInteractions(mockSubscribeRequest);
    });
  });

  test('unsubscribe_whenNoPendingSubscription_thenReturnsTrueAndSkipsRequest', () async {
    // ACT
    final result = await testee.unsubscribe();

    // VERIFY
    expect(result, isTrue);
    verifyNever(
      mockUnsubscribeRequest.call(
        evu: anyNamed('evu'),
        trainNumber: anyNamed('trainNumber'),
        pushToken: anyNamed('pushToken'),
        deviceId: anyNamed('deviceId'),
        messageId: anyNamed('messageId'),
        expiresAt: anyNamed('expiresAt'),
        isDriver: anyNamed('isDriver'),
      ),
    );
  });

  test('unsubscribe_whenNoTokenAvailable_thenReturnsFalseAndSkipsRequest', () async {
    // GIVEN
    // create a pending subscription (no push token initially)
    when(mockMessagingService.tokenValue).thenReturn(null);
    await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

    // ACT
    final result = await testee.unsubscribe();

    // VERIFY
    expect(result, isFalse);
    verifyNever(mockApiService.subscribe);
  });

  test('unsubscribe_whenRequestThrows_thenReturnsFalse', () async {
    // GIVEN
    // create a pending subscription (no push token initially)
    when(mockMessagingService.tokenValue).thenReturn(null);
    await testee.subscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );
    // token is now available for the unsubscribe call but API throws
    when(mockMessagingService.tokenValue).thenReturn(testPushToken);

    when(
      mockUnsubscribeRequest.call(
        evu: anyNamed('evu'),
        trainNumber: anyNamed('trainNumber'),
        pushToken: anyNamed('pushToken'),
        deviceId: anyNamed('deviceId'),
        messageId: anyNamed('messageId'),
        expiresAt: anyNamed('expiresAt'),
        isDriver: anyNamed('isDriver'),
      ),
    ).thenThrow(Exception('network error'));

    // ACT
    final result = await testee.unsubscribe();

    // VERIFY
    expect(result, isFalse);
    verify(
      mockUnsubscribeRequest.call(
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: testPushToken,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTimeWithBuffer,
        isDriver: true,
      ),
    ).called(1);
  });

  test('status_whenTrainStatusMessageReceived_thenEmitsStatusAndConfirmsMessage', () async {
    // GIVEN
    final emittedStatuses = <CustomerOrientedDeparture>[];
    final subscription = testee.customerOrientedDeparture.listen(emittedStatuses.add);

    // ACT
    rxMessage
      ..add(_createTrainStatusMessage(trainNumber: '1', status: 'READY', messageId: 'message-1'))
      ..add(_createTrainStatusMessage(trainNumber: '2', status: 'abcd', messageId: 'message-2')) // should be ignored
      ..add(_createTrainStatusMessage(trainNumber: '3', status: 'departure', messageId: 'message-3'));
    await Future.delayed(Duration.zero);

    // VERIFY
    expect(
      emittedStatuses,
      equals([
        CustomerOrientedDeparture(trainNumber: '1', status: .ready),
        CustomerOrientedDeparture(trainNumber: '3', status: .departure),
      ]),
    );

    final verificationResult = verify(
      mockConfirmRequest.call(
        messageId: captureAnyNamed('messageId'),
        deviceId: anyNamed('deviceId'),
      ),
    );
    verificationResult.called(2);

    final messageIds = verificationResult.captured;
    expect(messageIds, hasLength(2));
    expect(messageIds[0], 'message-1');
    expect(messageIds[1], 'message-3');

    await subscription.cancel();
  });

  test('requestLatestStatus_thenCallsReplayMessages', () async {
    // ACT
    testee.requestLatestStatus();

    // VERIFY
    verify(mockMessagingService.replayMessages()).called(1);
  });
}

TrainStatusMessageDto _createTrainStatusMessage({
  required String trainNumber,
  required String status,
  String messageId = 'message-1',
}) {
  return TrainStatusMessageDto(
    messageId: messageId,
    zugnr: trainNumber,
    bp: '1080',
    status: status,
  );
}
