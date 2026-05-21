import 'package:app/pages/journey/journey_screen/view_model/customer_oriented_departure_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:auth/component.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'customer_oriented_departure_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CustomerOrientedDepartureRepository>(),
  MockSpec<RuFeatureProvider>(),
  MockSpec<NotificationPriorityQueueViewModel>(),
  MockSpec<DASSounds>(),
  MockSpec<Sound>(),
  MockSpec<Authenticator>(),
  MockSpec<JourneyViewModel>(),
])
void main() {
  group('CustomerOrientedDepartureViewModel', () {
    late CustomerOrientedDepartureViewModel testee;
    late MockCustomerOrientedDepartureRepository mockRepository;
    late MockRuFeatureProvider mockRuFeatureProvider;
    late MockNotificationPriorityQueueViewModel mockNotificationViewModel;
    late MockAuthenticator mockAuthenticator;
    late MockDASSounds mockDasSounds;
    late MockJourneyViewModel mockJourneyViewModel;

    late BehaviorSubject<CustomerOrientedDeparture> rxCustomerOrientedDeparture;
    late BehaviorSubject<Journey?> rxJourney;
    late List<CustomerOrientedDepartureStatus> statusRegister;
    late FakeAsync testAsync;

    final mockSound = MockSound();

    final initialTrainNumber = 'INIT1234';
    final initialJourney = _createJourney(
      trainNumber: initialTrainNumber,
      journeyEndTime: DateTime.now(),
      ru: RailwayUndertaking.sbbP,
    );

    void setupTestee() {
      fakeAsync((fakeAsync) {
        testAsync = fakeAsync;

        testee = CustomerOrientedDepartureViewModel(
          repository: mockRepository,
          ruFeatureProvider: mockRuFeatureProvider,
          notificationViewModel: mockNotificationViewModel,
          authenticator: mockAuthenticator,
          journeyViewModel: mockJourneyViewModel,
        );

        statusRegister = [];
        testee.status.listen(statusRegister.add);
        processStreams(fakeAsync: fakeAsync);
      });
    }

    setUp(() {
      mockRepository = MockCustomerOrientedDepartureRepository();
      mockRuFeatureProvider = MockRuFeatureProvider();
      mockNotificationViewModel = MockNotificationPriorityQueueViewModel();
      mockDasSounds = MockDASSounds();
      mockAuthenticator = MockAuthenticator();
      mockJourneyViewModel = MockJourneyViewModel();

      rxCustomerOrientedDeparture = BehaviorSubject<CustomerOrientedDeparture>();
      rxJourney = BehaviorSubject<Journey?>.seeded(initialJourney);

      when(mockRepository.customerOrientedDeparture).thenAnswer((_) => rxCustomerOrientedDeparture.stream);
      when(mockJourneyViewModel.journey).thenAnswer((_) => rxJourney.stream);
      when(mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture)).thenAnswer(
        (_) => Future.value(true),
      );
      when(mockDasSounds.customerOrientedDeparture).thenReturn(mockSound);
      when(mockAuthenticator.user()).thenAnswer((_) => Future.value(User(userId: 'userId', roles: [Role.driver])));

      GetIt.I.registerSingleton<DASSounds>(mockDasSounds);

      setupTestee();
    });

    tearDown(() {
      testee.dispose();
      rxCustomerOrientedDeparture.close();
      rxJourney.close();
      GetIt.I.reset();
    });

    test('status_whenWaitAndFeatureEnabled_emitsAndInsertsNotificationWithoutSound', () {
      // ACT
      testAsync.run((_) {
        final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: initialTrainNumber, status: .wait);
        return rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      });
      processStreams(fakeAsync: testAsync);

      // VERIFY
      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.wait]));
      verifyInOrder([
        mockNotificationViewModel.remove(type: .customerOrientedDeparture),
        mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: null),
      ]);
    });

    test('status_whenReadyAndFeatureEnabled_emitsAndInsertsNotificationWithSound', () {
      // ACT
      testAsync.run((_) {
        final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: initialTrainNumber, status: .ready);
        return rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      });
      processStreams(fakeAsync: testAsync);

      // VERIFY
      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.ready]));
      verifyInOrder([
        mockNotificationViewModel.remove(type: .customerOrientedDeparture),
        mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: mockSound.play),
      ]);
    });

    test('status_whenDepartureAndFeatureEnabled_emitsAndOnlyRemovesNotification', () {
      // ACT
      testAsync.run((_) {
        final customerOrientedDeparture = CustomerOrientedDeparture(
          trainNumber: initialTrainNumber,
          status: .departure,
        );
        return rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      });
      processStreams(fakeAsync: testAsync);

      // VERIFY
      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.departure]));
      verify(mockNotificationViewModel.remove(type: .customerOrientedDeparture)).called(1);
      verifyNever(mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: anyNamed('callback')));
    });

    test('status_whenFeatureDisabled_doesNotEmitOrInsertButStillRemovesNotification', () {
      // WHEN
      when(
        mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture),
      ).thenAnswer((_) => Future.value(false));

      // ACT
      testAsync.run((_) {
        final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: initialTrainNumber, status: .call);
        return rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      });
      processStreams(fakeAsync: testAsync);

      // VERIFY
      expect(statusRegister, isEmpty);
      verify(mockNotificationViewModel.remove(type: .customerOrientedDeparture)).called(1);
      verifyNever(mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: anyNamed('callback')));
    });

    test('status_whenStatusForOtherTrain_doesNotEmitOrInsertNotification', () {
      // ACT
      testAsync.run((_) {
        final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: '1234', status: .call);
        return rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      });
      processStreams(fakeAsync: testAsync);

      // VERIFY
      expect(statusRegister, isEmpty);
      verifyNever(mockNotificationViewModel.remove(type: .customerOrientedDeparture));
      verifyNever(mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: anyNamed('callback')));
    });

    test('journeyIdentificationChanged_whenJourneyWithTrainId_thenSubscribesWithCorrectParameters', () async {
      // WHEN
      final journeyEndTime = DateTime.now();
      final journey = _createJourney(trainNumber: '9999', journeyEndTime: journeyEndTime, ru: RailwayUndertaking.sbbP);

      // ACT
      testAsync.run((_) => rxJourney.add(journey));
      processStreams(fakeAsync: testAsync);

      // VERIFY
      verify(
        mockRepository.subscribe(
          evu: RailwayUndertaking.sbbP.companyCode,
          trainNumber: '9999',
          journeyEndTime: journeyEndTime,
          isDriver: true,
        ),
      ).called(1);
    });

    test('journeyIdentificationChanged_whenJourneyWithoutTrainId_doesNotSubscribe', () async {
      // WHEN
      final journey = _createJourney(trainNumber: '9999', hasTrainId: false);

      // ACT
      testAsync.run((_) => rxJourney.add(journey));
      processStreams(fakeAsync: testAsync);

      // VERIFY
      verifyNever(
        mockRepository.subscribe(
          evu: anyNamed('evu'),
          trainNumber: '9999',
          journeyEndTime: anyNamed('journeyEndTime'),
          isDriver: anyNamed('isDriver'),
        ),
      );
    });

    test('journeyIdentificationChanged_whenJourneyChanges_unsubscribesBeforeResubscribing', () async {
      // WHEN
      final journey1 = _createJourney(trainNumber: '1111');
      final journey2 = _createJourney(trainNumber: '2222');

      // ACT
      testAsync.run((_) => rxJourney.add(journey1));
      processStreams(fakeAsync: testAsync);

      testAsync.run((_) => rxJourney.add(journey2));
      processStreams(fakeAsync: testAsync);

      // VERIFY
      verifyInOrder([
        mockRepository.subscribe(
          evu: anyNamed('evu'),
          trainNumber: '1111',
          journeyEndTime: anyNamed('journeyEndTime'),
          isDriver: anyNamed('isDriver'),
        ),
        mockRepository.unsubscribe(),
        mockRepository.subscribe(
          evu: anyNamed('evu'),
          trainNumber: '2222',
          journeyEndTime: anyNamed('journeyEndTime'),
          isDriver: anyNamed('isDriver'),
        ),
      ]);
    });

    test('journeyIdentificationChanged_whenNullJourney_doesNotSubscribeButUnsubscribesIfPreviousExists', () async {
      // WHEN
      final journey = _createJourney(trainNumber: '3333');

      // ACT
      testAsync.run((_) => rxJourney.add(journey));
      processStreams(fakeAsync: testAsync);

      testAsync.run((_) => rxJourney.add(null));
      processStreams(fakeAsync: testAsync);

      // VERIFY
      verify(mockRepository.unsubscribe()).called(2); // +1 from initial journey
      verify(
        mockRepository.subscribe(
          evu: anyNamed('evu'),
          trainNumber: '3333',
          journeyEndTime: anyNamed('journeyEndTime'),
          isDriver: anyNamed('isDriver'),
        ),
      ).called(1);
    });

    test('journeyIdentificationChanged_whenUserIsNotDriver_subscribesWithIsDriverFalse', () async {
      // WHEN
      when(mockAuthenticator.user()).thenAnswer((_) => Future.value(User(userId: 'userId', roles: [Role.observer])));
      final journey = _createJourney(trainNumber: '4444');

      // ACT
      testAsync.run((_) => rxJourney.add(journey));
      processStreams(fakeAsync: testAsync);

      // VERIFY
      verify(
        mockRepository.subscribe(
          evu: anyNamed('evu'),
          trainNumber: anyNamed('trainNumber'),
          journeyEndTime: anyNamed('journeyEndTime'),
          isDriver: false,
        ),
      ).called(1);
    });
  });
}

Journey _createJourney({
  required String trainNumber,
  RailwayUndertaking ru = RailwayUndertaking.sbbP,
  DateTime? journeyEndTime,
  bool hasTrainId = true,
}) {
  final endServicePoint = ServicePoint(
    name: 'Bern',
    abbreviation: 'BE',
    locationCode: 'CH',
    order: 100,
    kilometre: [],
    arrivalDepartureTime: ArrivalDepartureTime(ambiguousArrivalTime: journeyEndTime),
  );
  return Journey(
    metadata: Metadata(
      trainIdentification: hasTrainId
          ? TrainIdentification(
              ru: ru,
              trainNumber: trainNumber,
              date: journeyEndTime ?? DateTime(2026, 5, 5, 12),
            )
          : null,
    ),
    data: [endServicePoint],
  );
}
