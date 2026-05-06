import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/confirm/request.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:customer_oriented_departure/src/repository/customer_oriented_departure_repository_impl.dart';
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
  late BehaviorSubject<String?> rxToken;
  late BehaviorSubject<TrainStatusMessageDto> rxTrainStatusMessage;

  const String testPushToken = 'push-token';
  final testJourneyEndTime = DateTime.now();

  setUp(() {
    mockApiService = MockCustomerOrientedDepartureApiService();
    mockMessagingService = MockMessagingService();
    mockConfirmRequest = MockConfirmRequest();
    mockSubscribeRequest = MockSubscribeRequest();
    rxToken = BehaviorSubject();
    rxTrainStatusMessage = BehaviorSubject();

    when(mockApiService.subscribe).thenReturn(mockSubscribeRequest);
    when(mockApiService.confirm).thenReturn(mockConfirmRequest);
    when(mockMessagingService.tokenValue).thenReturn(testPushToken);
    when(mockMessagingService.token).thenAnswer((_) => rxToken.stream);
    when(mockMessagingService.message).thenAnswer((_) => rxTrainStatusMessage.stream);

    when(
      mockSubscribeRequest.call(
        type: anyNamed('type'),
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
    await rxTrainStatusMessage.close();
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
        type: SubscribeRequestType.register,
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: testPushToken,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
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
      mockSubscribeRequest.call(
        type: SubscribeRequestType.deregister,
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: 'new-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
        isDriver: true,
      ),
      mockSubscribeRequest.call(
        type: SubscribeRequestType.register,
        evu: '1180',
        trainNumber: 'RB77',
        pushToken: 'new-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
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
        type: SubscribeRequestType.register,
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: null,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
        isDriver: true,
      ),
    );
    verify(
      mockSubscribeRequest.call(
        type: SubscribeRequestType.register,
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: 'refreshed-token',
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
        isDriver: true,
      ),
    ).called(1);
  });

  test('unsubscribe_whenNoPendingSubscription_thenReturnsTrueAndSkipsRequest', () async {
    // ACT
    final result = await testee.unsubscribe();

    // VERIFY
    expect(result, isTrue);
    verifyNever(
      mockSubscribeRequest.call(
        type: SubscribeRequestType.deregister,
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
      mockSubscribeRequest.call(
        type: anyNamed('type'),
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
      mockSubscribeRequest.call(
        type: SubscribeRequestType.deregister,
        evu: '1080',
        trainNumber: 'RE1234',
        pushToken: testPushToken,
        deviceId: 'device-1',
        messageId: anyNamed('messageId'),
        expiresAt: testJourneyEndTime,
        isDriver: true,
      ),
    ).called(1);
  });

  test('status_whenTrainStatusMessageReceived_thenEmitsStatusAndConfirmsMessage', () async {
    // GIVEN
    final emittedStatuses = <CustomerOrientedDeparture>[];
    final subscription = testee.customerOrientedDeparture.listen(emittedStatuses.add);

    // ACT
    rxTrainStatusMessage
      ..add(_createMessage(trainNumber: '1', status: 'READY', messageId: 'message-1'))
      ..add(_createMessage(trainNumber: '2', status: 'abcd', messageId: 'message-2')) // should be ignored
      ..add(_createMessage(trainNumber: '3', status: 'departure', messageId: 'message-3'));
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
}

TrainStatusMessageDto _createMessage({
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
