import 'dart:async';
import 'dart:collection';

import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/advised_speed_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/delay_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/calculated_speed.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'chronograph_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CalculatedSpeedViewModel>(),
  MockSpec<JourneyViewModel>(),
])
void main() {
  const testDelay = Delay(value: Duration(seconds: 10), location: 'Bern');
  const aServicePoint = ServicePoint(name: 'A', abbreviation: '', locationCode: '', order: 0, kilometre: []);
  const bServicePoint = ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 10, kilometre: []);
  final testHiddenModel = DelayModel.hidden();
  final testStaleModel = DelayModel.stale(delay: testDelay);
  final testVisibleModel = DelayModel.visible(delay: testDelay);

  late Clock testClock;
  late ChronographViewModel testee;
  late BehaviorSubject<Journey?> rxMockJourney;
  late BehaviorSubject<AdvisedSpeedModel> rxMockAdvisedSpeedModel;
  late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
  late BehaviorSubject<DelayModel> rxMockPunctuality;
  late BehaviorSubject<Duration?> rxMockPlannedTimeDelay;
  late StreamSubscription punctualitySubscription;
  late StreamSubscription formattedWallclockTimeSubscription;
  late List<DelayModel> punctualityEmitRegister;
  late List<String> formattedWallclockTimeRegister;
  late FakeAsync testAsync;
  late CalculatedSpeedViewModel mockCalculatedSpeedViewModel;
  late MockJourneyViewModel mockJourneyViewModel;

  final activeAdvisedSpeedModel = AdvisedSpeedModel.active(
    segment: VelocityMaxAdvisedSpeedSegment(
      startOrder: 0,
      endOrder: 1,
      endData: Signal(order: 1, kilometre: []),
    ),
  );

  final journeyWithoutSpeed = Journey(
    metadata: Metadata(),
    data: [],
  );

  final journeyWithSpeed = Journey(
    metadata: Metadata(
      calculatedSpeeds: SplayTreeMap.of({10: SingleSpeed(value: '100')}),
    ),
    data: [],
  );

  setUp(() {
    testClock = Clock.fixed(clock.now());
    mockCalculatedSpeedViewModel = MockCalculatedSpeedViewModel();
    mockJourneyViewModel = MockJourneyViewModel();
    when(
      mockCalculatedSpeedViewModel.getCalculatedSpeedForOrder(bServicePoint.order),
    ).thenReturn(CalculatedSpeed(speed: SingleSpeed(value: '100')));
    when(
      mockCalculatedSpeedViewModel.getCalculatedSpeedForOrder(aServicePoint.order),
    ).thenReturn(CalculatedSpeed.none());

    fakeAsync((fakeAsync) {
      rxMockJourney = BehaviorSubject<Journey?>();
      when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      rxMockAdvisedSpeedModel = BehaviorSubject<AdvisedSpeedModel>.seeded(AdvisedSpeedModel.inactive());
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      rxMockPunctuality = BehaviorSubject<DelayModel>.seeded(DelayModel.hidden());
      rxMockPlannedTimeDelay = BehaviorSubject<Duration?>.seeded(null);
      testAsync = fakeAsync;
      formattedWallclockTimeRegister = <String>[];
      withClock(testClock, () {
        testee = ChronographViewModel(
          journeyPositionStream: rxMockJourneyPosition.stream,
          delayStream: rxMockPunctuality.stream,
          plannedTimeDelayStream: rxMockPlannedTimeDelay.stream,
          journeyViewModel: mockJourneyViewModel,
          advisedSpeedModelStream: rxMockAdvisedSpeedModel.stream,
          calculatedSpeedViewModel: mockCalculatedSpeedViewModel,
        );
        formattedWallclockTimeSubscription = testee.formattedWallclockTime.listen(formattedWallclockTimeRegister.add);
      });
      punctualityEmitRegister = <DelayModel>[];
      punctualitySubscription = testee.punctualityModel.listen(punctualityEmitRegister.add);
      _processStreamInFakeAsync(fakeAsync);
    });
  });

  tearDown(() {
    punctualitySubscription.cancel();
    formattedWallclockTimeSubscription.cancel();
    punctualityEmitRegister.clear();
    testee.dispose();
    rxMockJourney.close();
    rxMockAdvisedSpeedModel.close();
    rxMockPunctuality.close();
    rxMockPlannedTimeDelay.close();
    rxMockJourneyPosition.close();
    GetIt.I.reset();
  });

  test('formattedWallClockTimeValue_withFixedTime_shouldReturnFixedTime', () {
    final apolloElevenTouchdown = Clock.fixed(DateTime(1969, 07, 20, 2, 56, 0));
    withClock(apolloElevenTouchdown, () {
      final actual = testee.formattedWallclockTimeValue;
      expect(actual, equals('02:56:00'));
    });
  });

  test('formattedWallClockTime_withFixedTime_shouldEmitFixedFormattedTimes', () {
    testAsync.elapse(const Duration(seconds: 3));
    expect(formattedWallclockTimeRegister, isNotEmpty);
    expect(formattedWallclockTimeRegister, hasLength(1));
    expect(formattedWallclockTimeRegister.first, equals(DateFormat('HH:mm:ss').format(testClock.now())));
  });

  test('punctualityModelValue_whenNoStateAdded_IsHiddenByDefault', () {
    expect(testee.punctualityModelValue, equals(testHiddenModel));
  });

  test('punctualityModelValue_whenJourneyUpdateWithNull_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(punctualityEmitRegister.first, equals(testHiddenModel));
    punctualityEmitRegister.clear();

    // ACT
    testAsync.run((_) => rxMockJourney.add(null));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(punctualityEmitRegister, hasLength(0));
    expect(testee.punctualityModelValue, equals(testHiddenModel));
  });

  group('Journey_Delay_NoSpeeds_', () {
    setUp(() {
      testAsync.run((_) {
        punctualityEmitRegister.clear();
        rxMockJourney.add(journeyWithoutSpeed);
        rxMockPunctuality.add(testVisibleModel);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityModel_staysHiddenAndDoesNotEmit', () {
      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_StalePunctuality_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) => rxMockPunctuality.add(testStaleModel));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_HiddenPunctuality_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) => rxMockPunctuality.add(testHiddenModel));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_AdlIsInactive_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) {
        rxMockAdvisedSpeedModel.add(activeAdvisedSpeedModel);
        rxMockAdvisedSpeedModel.add(AdvisedSpeedModel.inactive());
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_HasLastServicePoint_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) {
        rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: aServicePoint));
      });

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });
  });

  group('Journey_Delay_Speeds_', () {
    setUp(() {
      testAsync.run((_) {
        punctualityEmitRegister.clear();
        rxMockJourney.add(journeyWithSpeed);
        rxMockPunctuality.add(testVisibleModel);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityModel_NoServicePoint_staysHiddenAndDoesNotEmit', () {
      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_ServicePointWithoutCalculatedSpeed_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) {
        rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: aServicePoint));
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_ServicePointWithCalculatedSpeed_emitsVisible', () {
      // ACT
      testAsync.run((_) {
        rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(testee.punctualityModelValue, equals(testVisibleModel));
    });

    test(
      'punctualityModel_ServicePointWithCalculatedSpeedAndAdlActive_staysHiddenDoesNotEmit',
      () {
        // ACT
        testAsync.run((_) {
          rxMockAdvisedSpeedModel.add(activeAdvisedSpeedModel);
          rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(punctualityEmitRegister, hasLength(0));
        expect(testee.punctualityModelValue, equals(testHiddenModel));
      },
    );

    test(
      'punctualityModel_ServicePointWithCalculatedSpeedAndAdlActiveInactive_emits',
      () {
        // ACT
        testAsync.run((_) {
          rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
          rxMockAdvisedSpeedModel.add(activeAdvisedSpeedModel);
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(punctualityEmitRegister, hasLength(2));
        expect(punctualityEmitRegister, orderedEquals([testVisibleModel, testHiddenModel]));
        expect(testee.punctualityModelValue, equals(testHiddenModel));
      },
    );

    test(
      'punctualityModel_ServicePointWithCalculatedAndStale_emits',
      () {
        // ACT
        testAsync.run((_) {
          rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
          rxMockPunctuality.add(testStaleModel);
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(punctualityEmitRegister, hasLength(2));
        expect(punctualityEmitRegister, orderedEquals([testVisibleModel, testStaleModel]));
        expect(testee.punctualityModelValue, equals(testStaleModel));
      },
    );

    test(
      'punctualityModel_ServicePointWithCalculatedAndStaleHidden_emits',
      () {
        // ACT
        testAsync.run((_) {
          rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
          rxMockPunctuality.add(testStaleModel);
          rxMockPunctuality.add(testHiddenModel);
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(punctualityEmitRegister, hasLength(3));
        expect(punctualityEmitRegister, orderedEquals([testVisibleModel, testStaleModel, testHiddenModel]));
        expect(testee.punctualityModelValue, equals(testHiddenModel));
      },
    );
  });

  group('Journey_Delay_Speeds_PlannedTimeDelay_', () {
    const testPlannedTimeDelayVisible = Duration(minutes: 30);
    final testPunctualityPlannedTimeDeviation = DelayModel.plannedTimeDeviation(
      deviation: const Duration(minutes: 30),
    );

    setUp(() {
      testAsync.run((_) {
        punctualityEmitRegister.clear();
        rxMockJourney.add(journeyWithSpeed);
        rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: bServicePoint));
      });
      _processStreamInFakeAsync(testAsync);
    });

    test('punctualityModel_whenOnlyPlannedTimeDelayIsVisible_thenEmitsPlannedTimeDeviation', () {
      // ACT
      testAsync.run((_) => rxMockPlannedTimeDelay.add(testPlannedTimeDelayVisible));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(punctualityEmitRegister.first, equals(testPunctualityPlannedTimeDeviation));
      expect(testee.punctualityModelValue, equals(testPunctualityPlannedTimeDeviation));
    });

    test('punctualityModel_whenSferaPunctualityAndPlannedTimeDelayAreBothVisible_thenSferaPunctualityWins', () {
      // ACT
      testAsync.run((_) {
        rxMockPlannedTimeDelay.add(testPlannedTimeDelayVisible);
        rxMockPunctuality.add(testVisibleModel);
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, orderedEquals([testPunctualityPlannedTimeDeviation, testVisibleModel]));
      expect(testee.punctualityModelValue, equals(testVisibleModel));
    });

    test(
      'punctualityModel_whenSferaPunctualityGoesHiddenWhilePlannedTimeDelayIsVisible_thenFallsBackToPlannedTime',
      () {
        // ACT
        testAsync.run((_) {
          rxMockPunctuality.add(testVisibleModel);
          rxMockPlannedTimeDelay.add(testPlannedTimeDelayVisible);
          rxMockPunctuality.add(testHiddenModel);
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(
          punctualityEmitRegister,
          orderedEquals([testVisibleModel, testPunctualityPlannedTimeDeviation]),
        );
        expect(testee.punctualityModelValue, equals(testPunctualityPlannedTimeDeviation));
      },
    );

    test('punctualityModel_whenBothSferaAndPlannedTimeDelayAreHidden_thenStaysHiddenAndDoesNotEmit', () {
      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test('punctualityModel_whenPlannedTimeDelayVisibleButAdlActive_thenStaysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.run((_) {
        rxMockAdvisedSpeedModel.add(activeAdvisedSpeedModel);
        rxMockPlannedTimeDelay.add(testPlannedTimeDelayVisible);
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, equals(testHiddenModel));
    });

    test(
      'punctualityModel_whenPlannedTimeDelayVisibleButNoCalculatedSpeedAtCurrentPosition_thenStaysHiddenAndDoesNotEmit',
      () {
        // ACT
        testAsync.run((_) {
          rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: aServicePoint));
          rxMockPlannedTimeDelay.add(testPlannedTimeDelayVisible);
        });
        _processStreamInFakeAsync(testAsync);

        // EXPECT
        expect(punctualityEmitRegister, hasLength(0));
        expect(testee.punctualityModelValue, equals(testHiddenModel));
      },
    );
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);
