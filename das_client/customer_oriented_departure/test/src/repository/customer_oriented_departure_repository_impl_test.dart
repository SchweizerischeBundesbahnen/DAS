import 'package:customer_oriented_departure/component.dart';
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
  MockSpec<SubscribeRequest>(),
])
void main() {
  late CustomerOrientedDepartureRepository testee;
  late MockCustomerOrientedDepartureApiService mockApiService;
  late MockMessagingService mockMessagingService;
  late MockSubscribeRequest mockSubscribeRequest;
  late BehaviorSubject<String?> rxToken;
  late BehaviorSubject<TrainStatusMessageDto> rxTrainStatusMessage;

  const String testPushToken = 'push-token';
  final testJourneyEndTime = DateTime.now();

  setUp(() {
    mockApiService = MockCustomerOrientedDepartureApiService();
    mockMessagingService = MockMessagingService();
    mockSubscribeRequest = MockSubscribeRequest();
    rxToken = BehaviorSubject();
    rxTrainStatusMessage = BehaviorSubject();

    when(mockApiService.subscribe).thenReturn(mockSubscribeRequest);
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

    testee = CustomerOrientedDepartureRepositoryImpl(
      apiService: mockApiService,
      messagingService: mockMessagingService,
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
      deviceId: 'device-1',
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
      deviceId: 'device-1',
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
      deviceId: 'device-1',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );
    when(mockMessagingService.tokenValue).thenReturn('new-token');

    // ACT
    final result = await testee.subscribe(
      evu: '1180',
      trainNumber: 'RB77',
      deviceId: 'device-2',
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
        deviceId: 'device-2',
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
      deviceId: 'device-1',
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

  test('unsubscribe_whenNoTokenAvailable_thenReturnsFalseAndSkipsRequest', () async {
    // GIVEN
    when(mockMessagingService.tokenValue).thenReturn(null);

    // ACT
    final result = await testee.unsubscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      deviceId: 'device-1',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

    // VERIFY
    expect(result, isFalse);
    verifyNever(mockApiService.subscribe);
  });

  test('unsubscribe_whenRequestThrows_thenReturnsFalse', () async {
    // GIVEN
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
    final result = await testee.unsubscribe(
      evu: '1080',
      trainNumber: 'RE1234',
      deviceId: 'device-1',
      journeyEndTime: testJourneyEndTime,
      isDriver: true,
    );

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

  test('status_whenTrainStatusMessagesReceived_thenPublishesStatus', () async {
    // GIVEN
    final emittedStatuses = <CustomerOrientedDepartureStatus>[];
    final subscription = testee.status.listen(emittedStatuses.add);

    // ACT
    rxTrainStatusMessage
      ..add(_createMessage(status: 'READY'))
      ..add(_createMessage(status: 'abcd')) // should be ignored
      ..add(_createMessage(status: 'departure'));
    await Future.delayed(Duration.zero);

    // VERIFY
    expect(
      emittedStatuses,
      equals([
        CustomerOrientedDepartureStatus.ready,
        CustomerOrientedDepartureStatus.departure,
      ]),
    );

    await subscription.cancel();
  });
}

TrainStatusMessageDto _createMessage({required String status}) {
  return TrainStatusMessageDto(
    messageId: 'message-1',
    zugnr: 'RE1234',
    bp: '1080',
    status: status,
  );
}
