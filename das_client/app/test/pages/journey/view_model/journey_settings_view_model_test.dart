import 'dart:async';

import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';
import 'journey_settings_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  late JourneySettingsViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late BehaviorSubject<Journey?> rxMockJourney;
  late StreamSubscription<JourneySettings> modelSubscription;
  late List<dynamic> emitRegister;
  bool onBreakSeriesUpdatedCalled = false;

  setUp(() {
    onBreakSeriesUpdatedCalled = false;
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
    when(mockJourneyTableViewModel.journey).thenAnswer((_) => rxMockJourney.stream);

    testee = JourneySettingsViewModel(
      journeyTableViewModel: mockJourneyTableViewModel,
    );
    emitRegister = <dynamic>[];
    modelSubscription = testee.model.listen(emitRegister.add);
    processStreams();

    emitRegister.clear();
  });

  tearDown(() {
    modelSubscription.cancel();
    emitRegister.clear();
    testee.dispose();
    rxMockJourney.close();
  });

  test('constructor_whenCalled_buildsSubscription', () => expect(rxMockJourney.hasListener, isTrue));

  test('updateBreakSeries_whenCalled_emitsCorrectBreakSeries', () {
    // ARRANGE
    final aBreakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100);
    // ACT
    testee.updateBreakSeries(aBreakSeries);
    processStreams();
    // EXPECT
    expect(testee.modelValue, equals(JourneySettings(selectedBreakSeries: aBreakSeries)));
    expect(emitRegister, hasLength(1));
  });

  test('registerOnBreakSeriesUpdated_whenCalledLater_callbackIsInvoked', () {
    // ARRANGE
    final aBreakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100);
    void laterCallback() {
      onBreakSeriesUpdatedCalled = true;
    }

    // ACT
    testee.registerOnBreakSeriesUpdated(laterCallback);
    testee.updateBreakSeries(aBreakSeries);
    processStreams();

    // EXPECT
    expect(onBreakSeriesUpdatedCalled, isTrue);
  });

  test('registerOnBreakSeriesUpdated_whenMultipleCallbacksRegistered_allAreInvoked', () {
    // ARRANGE
    final aBreakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100);
    bool secondCallbackCalled = false;
    bool thirdCallbackCalled = false;

    // ACT
    testee.registerOnBreakSeriesUpdated(() => secondCallbackCalled = true);
    testee.registerOnBreakSeriesUpdated(() => thirdCallbackCalled = true);
    testee.updateBreakSeries(aBreakSeries);
    processStreams();

    // EXPECT
    expect(secondCallbackCalled, isTrue);
    expect(thirdCallbackCalled, isTrue);
  });

  test('unregisterOnBreakSeriesUpdated_whenCalled_isNotInvokedAnymore', () {
    // ARRANGE
    final aBreakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100);
    void laterCallback() {
      onBreakSeriesUpdatedCalled = !onBreakSeriesUpdatedCalled;
    }

    testee.registerOnBreakSeriesUpdated(laterCallback);
    testee.updateBreakSeries(aBreakSeries);
    processStreams();
    expect(onBreakSeriesUpdatedCalled, isTrue);

    // ACT
    testee.unregisterOnBreakSeriesUpdated(laterCallback);
    testee.updateBreakSeries(aBreakSeries);
    processStreams();

    // EXPECT
    expect(onBreakSeriesUpdatedCalled, isTrue);
  });

  test('updateExpandedGroups_whenCalled_emitsCorrectExpandedGroups', () {
    // ARRANGE
    final aExpandedGroups = const [1, 2];

    // ACT
    testee.updateExpandedGroups(aExpandedGroups);
    processStreams();

    // EXPECT
    expect(testee.modelValue, equals(JourneySettings(expandedGroups: aExpandedGroups)));
    expect(emitRegister, hasLength(1));
    expect(onBreakSeriesUpdatedCalled, isFalse);
  });

  test('dispose_whenCalled_cancelsSubscription', () {
    // ACT
    testee.dispose();
    processStreams();

    // EXPECT
    expect(rxMockJourney.hasListener, isFalse);
  });
}
