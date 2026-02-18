import 'package:app/pages/journey/journey_screen/view_model/departure_dispatch_notification_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

@GenerateNiceMocks([MockSpec<DASSounds>(), MockSpec<Sound>(), MockSpec<SferaRepository>()])
import 'departure_dispatch_notification_view_model_test.mocks.dart';

void main() {
  group('Unit test departure dispatch notification viewmodel', () {
    late DepartureDispatchNotificationViewModel testee;
    late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
    late BehaviorSubject<DepartureDispatchNotificationEvent?> eventSubject;
    late SferaRepository mockSferaRepo;
    late DASSounds mockDasSounds;
    late FakeAsync testAsync;
    final Sound mockSound = MockSound();
    late List<DepartureDispatchNotificationType?> streamRegister;

    final baseJourney = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 9, kilometre: []),
        ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 10, kilometre: []),
        Signal(order: 11, kilometre: []),
        Signal(order: 19, kilometre: []),
        ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 20, kilometre: []),
        Signal(order: 21, kilometre: []),
        Signal(order: 29, kilometre: []),
        ServicePoint(name: 'D', abbreviation: '', locationCode: '', order: 30, kilometre: []),
        Signal(order: 31, kilometre: []),
      ],
    );

    setUp(() {
      mockDasSounds = MockDASSounds();
      mockSferaRepo = MockSferaRepository();
      when(mockDasSounds.departureDispatchNotification).thenReturn(mockSound);
      GetIt.I.registerSingleton<DASSounds>(mockDasSounds);

      fakeAsync((fakeAsync) {
        journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
        eventSubject = BehaviorSubject<DepartureDispatchNotificationEvent?>.seeded(null);
        when(mockSferaRepo.departureDispatchNotificationEventStream).thenAnswer((_) => eventSubject.stream);
        testAsync = fakeAsync;

        testee = DepartureDispatchNotificationViewModel(
          sferaRepo: mockSferaRepo,
          journeyPositionStream: journeyPositionSubject,
        );
        streamRegister = [];
        testee.type.listen(streamRegister.add);
        _processStreamInFakeAsync(fakeAsync);
      });
    });

    tearDown(() {
      reset(mockSound);
      reset(mockDasSounds);
      journeyPositionSubject.close();
      testee.dispose();
      GetIt.I.reset();
    });

    test('whenHasNoEventAndNoPosition_doesNotEmitAndPlaySound', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: null));
        eventSubject.add(null);
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(streamRegister, [null]);
      verifyNever(mockSound.play());
    });

    test('whenHasNoEventButPosition_doesNotEmitAndPlaySound', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: baseJourney.data[1] as JourneyPoint));
        eventSubject.add(null);
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(streamRegister, [null]);
      verifyNever(mockSound.play());
    });

    test('whenEventAndPosition_doesNotEmitAndPlaySound', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: baseJourney.data[1] as JourneyPoint));
        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDeparture),
        );
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(streamRegister, [null]);
      verifyNever(mockSound.play());
    });

    test('whenEventsAndNoPosition_doesEmitAndPlaySound', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: null));
        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDepartureShort),
        );
        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDeparture),
        );
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(
        streamRegister,
        orderedEquals([
          null,
          DepartureDispatchNotificationType.prepareForDepartureShort,
          DepartureDispatchNotificationType.prepareForDeparture,
        ]),
      );
      verify(mockSound.play()).called(2);
    });

    test('whenEventOfSameTypeAndNoPosition_doesEmitAndPlaySoundOnce', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: null));
        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDepartureShort),
        );
        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDepartureShort),
        );
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(
        streamRegister,
        orderedEquals([null, DepartureDispatchNotificationType.prepareForDepartureShort]),
      );
      verify(mockSound.play()).called(1);
    });

    test('whenEventsAfterPosition_doesEmitAndPlaySoundOnlyBeforePositionUpdate', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(lastPosition: null));
        _processStreamInFakeAsync(testAsync);

        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDepartureMiddle),
        );
        _processStreamInFakeAsync(testAsync);

        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.departureProvisionWithdrawn),
        );
        _processStreamInFakeAsync(testAsync);

        journeyPositionSubject.add(JourneyPositionModel(lastPosition: baseJourney.data[1] as JourneyPoint));
        _processStreamInFakeAsync(testAsync);

        eventSubject.add(
          DepartureDispatchNotificationEvent(type: DepartureDispatchNotificationType.prepareForDepartureShort),
        );
        _processStreamInFakeAsync(testAsync);
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(
        streamRegister,
        orderedEquals([
          null,
          DepartureDispatchNotificationType.prepareForDepartureMiddle,
          DepartureDispatchNotificationType.departureProvisionWithdrawn,
          null,
        ]),
      );
      verify(mockSound.play()).called(2);
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.flushMicrotasks();
