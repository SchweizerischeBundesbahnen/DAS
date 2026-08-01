import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/planned_time_delay_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'planned_time_delay_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<RuFeatureProvider>(),
])
void main() {
  // TEST JOURNEY overview
  // A departs 20:00
  // B arrives 20:40 (through-travel),
  // C arrives 21:30
  // D arrives 22:00.
  // E no times
  final servicePointA = ServicePoint(
    name: 'A',
    abbreviation: 'A',
    locationCode: 'A',
    order: 0,
    kilometre: const [],
    arrivalDepartureTime: ArrivalDepartureTime(plannedDepartureTime: DateTime(2024, 1, 1, 20, 0)),
  );
  final servicePointB = ServicePoint(
    name: 'B',
    abbreviation: 'B',
    locationCode: 'B',
    order: 1,
    kilometre: const [],
    arrivalDepartureTime: ArrivalDepartureTime(plannedArrivalTime: DateTime(2024, 1, 1, 20, 40)),
  );
  final servicePointC = ServicePoint(
    name: 'C',
    abbreviation: 'C',
    locationCode: 'C',
    order: 2,
    kilometre: const [],
    arrivalDepartureTime: ArrivalDepartureTime(plannedArrivalTime: DateTime(2024, 1, 1, 21, 30)),
  );
  final servicePointD = ServicePoint(
    name: 'D',
    abbreviation: 'D',
    locationCode: 'D',
    order: 3,
    kilometre: const [],
    arrivalDepartureTime: ArrivalDepartureTime(plannedArrivalTime: DateTime(2024, 1, 1, 22, 0)),
  );
  final servicePointWithoutTimes = ServicePoint(
    name: 'E',
    abbreviation: 'E',
    locationCode: 'E',
    order: 4,
    kilometre: const [],
  );
  const aSignal = Signal(order: 0, kilometre: []);

  late PlannedTimeDelayViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockRuFeatureProvider mockRuFeatureProvider;
  late BehaviorSubject<Journey?> rxMockJourney;
  late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
  late StreamSubscription modelSubscription;
  late List<Duration?> emitRegister;
  late FakeAsync testAsync;

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    mockRuFeatureProvider = MockRuFeatureProvider();
    when(mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.plannedTimeDeviation)).thenAnswer((_) async => true);

    withClock(Clock.fixed(DateTime(2024, 1, 1, 20, 0)), () {
      fakeAsync((fakeAsync) {
        rxMockJourney = BehaviorSubject<Journey?>();
        when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
        rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
        testAsync = fakeAsync;
        testee = PlannedTimeDelayViewModel(
          journeyPositionStream: rxMockJourneyPosition.stream,
          ruFeatureProvider: mockRuFeatureProvider,
          journeyViewModel: mockJourneyViewModel,
        );
        emitRegister = <Duration?>[];
        modelSubscription = testee.model.listen(emitRegister.add);
        rxMockJourney.add(Journey(metadata: Metadata(), data: []));
        processStreams(fakeAsync: fakeAsync);
      });
    });
  });

  tearDown(() {
    modelSubscription.cancel();
    testee.dispose();
    rxMockJourney.close();
    rxMockJourneyPosition.close();
  });

  test(
    'modelValue_whenNoStateAdded_IsHiddenByDefault',
    () => expect(testee.modelValue, isNull),
  );

  test('model_whenCurrentPositionIsNotAServicePoint_thenStaysHiddenAndDoesNotEmit', () {
    // ARRANGE
    expect(emitRegister.first, isNull);
    emitRegister.clear();

    // ACT
    testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: aSignal)));
    processStreams(fakeAsync: testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.modelValue, isNull);
  });

  test('model_whenPositionOnFirstServicePoint_thenStaysHiddenAndDoesNotEmit', () {
    // ARRANGE
    expect(emitRegister.first, isNull);
    emitRegister.clear();

    // ACT
    testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointA)));
    processStreams(fakeAsync: testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.modelValue, isNull);
  });

  group('after first service point', () {
    setUp(() {
      testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointA)));
      processStreams(fakeAsync: testAsync);
      emitRegister.clear();
    });

    test('model_whenRuFeatureIsDisabled_thenEmitsNothing', () {
      // ARRANGE
      when(
        mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.plannedTimeDeviation),
      ).thenAnswer((_) async => false);
      testAsync.run((_) => rxMockJourney.add(Journey(metadata: Metadata(), data: [])));
      processStreams(fakeAsync: testAsync);

      // ACT
      testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
      testAsync.run(
        (_) => rxMockJourneyPosition.add(
          JourneyPositionModel(currentPosition: servicePointB, lastPosition: servicePointA),
        ),
      );
      processStreams(fakeAsync: testAsync);

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.modelValue, isNull);
    });

    test('model_whenPositionAdvancesThroughMultipleServicePoints_thenRecalculatesEachTime', () {
      // ACT
      testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
      testAsync.run(
        (_) => rxMockJourneyPosition.add(
          JourneyPositionModel(currentPosition: servicePointB, lastPosition: servicePointA),
        ),
      );
      processStreams(fakeAsync: testAsync);

      testAsync.elapse(const Duration(hours: 1, minutes: 30)); // now: 22:00
      testAsync.run(
        (_) => rxMockJourneyPosition.add(
          JourneyPositionModel(currentPosition: servicePointC, lastPosition: servicePointB),
        ),
      );
      processStreams(fakeAsync: testAsync);

      testAsync.elapse(const Duration(hours: 1, minutes: 30)); // now: 23:30
      testAsync.run(
        (_) => rxMockJourneyPosition.add(
          JourneyPositionModel(currentPosition: servicePointD, lastPosition: servicePointC),
        ),
      );
      processStreams(fakeAsync: testAsync);

      // EXPECT
      expect(
        emitRegister,
        orderedEquals([
          const Duration(minutes: -10),
          const Duration(minutes: 30),
          const Duration(minutes: 90),
        ]),
      );
    });

    test('model_whenCurrentPositionAndLastPositionAreEqual_thenDoesNotRecalculate', () {
      // ARRANGE
      testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
      testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointB)));
      processStreams(fakeAsync: testAsync);
      emitRegister.clear();

      // ACT
      testAsync.elapse(const Duration(minutes: 5)); // now: 20:35
      testAsync.run(
        (_) => rxMockJourneyPosition.add(
          JourneyPositionModel(currentPosition: servicePointB, lastPosition: servicePointB),
        ),
      );
      processStreams(fakeAsync: testAsync);

      // EXPECT
      expect(emitRegister, hasLength(0));
    });

    test('model_whenMultipleServicePointsProcessedForSameJourney_thenChecksFeatureOnlyOncePerJourneyUpdate', () {
      // ACT
      testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
      testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointB)));
      processStreams(fakeAsync: testAsync);

      testAsync.elapse(const Duration(hours: 1, minutes: 30)); // now: 22:00
      testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointC)));
      processStreams(fakeAsync: testAsync);

      // EXPECT: only the single call made during setUp's journey update, not once per service point above.
      verify(mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.plannedTimeDeviation)).called(1);
    });

    test(
      'model_whenRuFeatureFlagChangesWithoutJourneyUpdate_thenKeepsUsingPreviouslyResolvedValue',
      () {
        // ARRANGE: the feature was already resolved as enabled once for this journey in setUp.
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.plannedTimeDeviation),
        ).thenAnswer((_) async => false);

        // ACT: no journey update happens here, so the cached (enabled) value should still be used.
        testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
        testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointB)));
        processStreams(fakeAsync: testAsync);

        // EXPECT
        expect(emitRegister, hasLength(1));
        expect(emitRegister.first, equals(const Duration(minutes: -10)));
      },
    );

    test('model_whenServicePointHasNoPlannedTime_thenDoesNotEmit', () {
      // ACT
      testAsync.elapse(const Duration(minutes: 30)); // now: 20:30
      testAsync.run(
        (_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointWithoutTimes)),
      );
      processStreams(fakeAsync: testAsync);

      testAsync.elapse(const Duration(minutes: 30)); // now: 21:00
      testAsync.run((_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointWithoutTimes)));
      processStreams(fakeAsync: testAsync);

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.modelValue, isNull);
    });

    test('model_whenServicePointHasNoPlannedTimeAfterFullServicePoint_thenDoesNotEmitAnyMore', () {
      // ACT
      testAsync.elapse(const Duration(minutes: 30));
      testAsync.run(
        (_) => rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: servicePointB)),
      );
      processStreams(fakeAsync: testAsync);

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.modelValue, const Duration(minutes: -10));
    });
  });
}
