import 'package:app/pages/journey/journey_screen/view_model/customer_oriented_departure_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';

import '../../../../test_util.dart';
import 'customer_oriented_departure_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CustomerOrientedDepartureRepository>(),
  MockSpec<RuFeatureProvider>(),
  MockSpec<NotificationPriorityQueueViewModel>(),
  MockSpec<DASSounds>(),
  MockSpec<Sound>(),
])
void main() {
  group('CustomerOrientedDepartureViewModel', () {
    late CustomerOrientedDepartureViewModel testee;
    late MockCustomerOrientedDepartureRepository mockRepository;
    late MockRuFeatureProvider mockRuFeatureProvider;
    late MockNotificationPriorityQueueViewModel mockNotificationViewModel;
    late MockDASSounds mockDasSounds;

    late BehaviorSubject<CustomerOrientedDepartureStatus> rxStatus;
    late List<CustomerOrientedDepartureStatus> statusRegister;
    late FakeAsync testAsync;

    final mockSound = MockSound();

    void setupTestee() {
      fakeAsync((fakeAsync) {
        testAsync = fakeAsync;

        testee = CustomerOrientedDepartureViewModel(
          repository: mockRepository,
          ruFeatureProvider: mockRuFeatureProvider,
          notificationViewModel: mockNotificationViewModel,
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

      rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>();

      when(mockRepository.status).thenAnswer((_) => rxStatus.stream);
      when(mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture)).thenAnswer(
        (_) => Future.value(true),
      );
      when(mockDasSounds.customerOrientedDeparture).thenReturn(mockSound);

      GetIt.I.registerSingleton<DASSounds>(mockDasSounds);

      setupTestee();
    });

    tearDown(() {
      testee.dispose();
      rxStatus.close();
      GetIt.I.reset();
    });

    test('status_whenWaitAndFeatureEnabled_emitsAndInsertsNotificationWithoutSound', () {
      testAsync.run((_) => rxStatus.add(.wait));
      processStreams(fakeAsync: testAsync);

      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.wait]));
      verifyInOrder([
        mockNotificationViewModel.remove(type: .customerOrientedDeparture),
        mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: null),
      ]);
    });

    test('status_whenReadyAndFeatureEnabled_emitsAndInsertsNotificationWithSound', () {
      testAsync.run((_) => rxStatus.add(.ready));
      processStreams(fakeAsync: testAsync);

      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.ready]));
      verifyInOrder([
        mockNotificationViewModel.remove(type: .customerOrientedDeparture),
        mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: mockSound.play),
      ]);
    });

    test('status_whenDepartureAndFeatureEnabled_emitsAndOnlyRemovesNotification', () {
      testAsync.run((_) => rxStatus.add(.departure));
      processStreams(fakeAsync: testAsync);

      expect(statusRegister, orderedEquals([CustomerOrientedDepartureStatus.departure]));
      verify(mockNotificationViewModel.remove(type: .customerOrientedDeparture)).called(1);
      verifyNever(mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: anyNamed('callback')));
    });

    test('status_whenFeatureDisabled_doesNotEmitOrInsertButStillRemovesNotification', () {
      when(
        mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture),
      ).thenAnswer((_) => Future.value(false));

      testAsync.run((_) => rxStatus.add(.call));
      processStreams(fakeAsync: testAsync);

      expect(statusRegister, isEmpty);
      verify(mockNotificationViewModel.remove(type: .customerOrientedDeparture)).called(1);
      verifyNever(mockNotificationViewModel.insert(type: .customerOrientedDeparture, callback: anyNamed('callback')));
    });
  });
}
