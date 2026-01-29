import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/punctuality_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'punctuality_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  const timeConstants = TimeConstants();
  const testDelay = Delay(value: Duration(seconds: 10), location: 'Bern');
  final testHiddenModel = PunctualityModel.hidden();
  final testStaleModel = PunctualityModel.stale(delay: testDelay);
  final testVisibleModel = PunctualityModel.visible(delay: testDelay);

  late Clock testClock;
  late PunctualityViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late BehaviorSubject<Journey?> rxMockJourney;
  late StreamSubscription modelSubscription;
  late List<PunctualityModel> emitRegister;
  late FakeAsync testAsync;

  final journeyWithDelay = Journey(
    metadata: Metadata(delay: testDelay),
    data: [],
  );

  final journeyWithoutDelay = Journey(
    metadata: Metadata(),
    data: [],
  );

  setUp(() {
    GetIt.I.registerSingleton<TimeConstants>(timeConstants);
    testClock = Clock.fixed(clock.now());
    fakeAsync((fakeAsync) {
      rxMockJourney = BehaviorSubject<Journey?>();
      mockJourneyTableViewModel = MockJourneyTableViewModel();
      when(mockJourneyTableViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      testAsync = fakeAsync;
      withClock(testClock, () {
        testee = PunctualityViewModel(journeyTableViewModel: mockJourneyTableViewModel);
      });
      emitRegister = <PunctualityModel>[];
      modelSubscription = testee.model.listen(emitRegister.add);
      _processStreamInFakeAsync(fakeAsync);
    });
  });

  tearDown(() {
    modelSubscription.cancel();
    testee.dispose();
    rxMockJourney.close();
    GetIt.I.reset();
  });

  test(
    'modelValue_whenNoStateAdded_IsHiddenByDefault',
    () => expect(testee.modelValue, testHiddenModel),
  );

  test('modelValue_whenJourneyUpdateWithNull_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(emitRegister.first, equals(testHiddenModel));
    emitRegister.clear();

    // ACT
    testAsync.run((_) => rxMockJourney.add(null));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.modelValue, equals(testHiddenModel));
  });

  test('model_whenJourneyUpdateWithoutDelay_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(emitRegister.first, equals(testHiddenModel));
    emitRegister.clear();

    // ACT
    testAsync.run((_) => rxMockJourney.add(journeyWithoutDelay));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.modelValue, equals(testHiddenModel));
  });

  group('journey with delay', () {
    setUp(() {
      testAsync.run((_) {
        emitRegister.clear();
        rxMockJourney.add(journeyWithDelay);
        _processStreamInFakeAsync(testAsync);
      });
    });
    test(
      'model_whenJourneyHasDelay_thenIsVisible',
      () => expect(emitRegister.first, equals(testVisibleModel)),
    );

    test('model_whenJourneyIsUpdatedWithNoDelay_thenGoesHidden', () {
      // ARRANGE
      expect(emitRegister.first, equals(testVisibleModel));
      emitRegister.clear();

      // ACT
      testAsync.run((_) => rxMockJourney.add(journeyWithoutDelay));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.modelValue, equals(testHiddenModel));
    });

    test('model_whenJourneyIsNotUpdatedForStaleTime_emitsStale', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister,
        orderedEquals([testVisibleModel, testStaleModel]),
      );
      expect(testee.modelValue, testStaleModel);
    });

    test('model_whenJourneyIsNotUpdatedForDisappearTime_emitsStaleThenHidden', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(3));
      expect(
        emitRegister,
        orderedEquals([testVisibleModel, testStaleModel, testHiddenModel]),
      );
      expect(testee.modelValue, testHiddenModel);
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);
