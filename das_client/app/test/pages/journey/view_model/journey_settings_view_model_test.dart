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
  bool onBrakeSeriesUpdatedCalled = false;

  setUp(() {
    onBrakeSeriesUpdatedCalled = false;
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

  test('updateBrakeSeries_whenCalled_emitsCorrectBrakeSeries', () {
    // ARRANGE
    final aBrakeSeries = BrakeSeries(trainSeries: TrainSeries.A, brakeSeries: 100);
    // ACT
    testee.updateBrakeSeries(aBrakeSeries);
    processStreams();
    // EXPECT
    expect(testee.modelValue, equals(JourneySettings(selectedBrakeSeries: aBrakeSeries)));
    expect(emitRegister, hasLength(1));
  });

  test('registerOnBrakeSeriesUpdated_whenCalledLater_callbackIsInvoked', () {
    // ARRANGE
    final aBrakeSeries = BrakeSeries(trainSeries: TrainSeries.A, brakeSeries: 100);
    void laterCallback() {
      onBrakeSeriesUpdatedCalled = true;
    }

    // ACT
    testee.registerOnBrakeSeriesUpdated(laterCallback);
    testee.updateBrakeSeries(aBrakeSeries);
    processStreams();

    // EXPECT
    expect(onBrakeSeriesUpdatedCalled, isTrue);
  });

  test('registerOnBrakeSeriesUpdated_whenMultipleCallbacksRegistered_allAreInvoked', () {
    // ARRANGE
    final aBrakeSeries = BrakeSeries(trainSeries: TrainSeries.A, brakeSeries: 100);
    bool secondCallbackCalled = false;
    bool thirdCallbackCalled = false;

    // ACT
    testee.registerOnBrakeSeriesUpdated(() => secondCallbackCalled = true);
    testee.registerOnBrakeSeriesUpdated(() => thirdCallbackCalled = true);
    testee.updateBrakeSeries(aBrakeSeries);
    processStreams();

    // EXPECT
    expect(secondCallbackCalled, isTrue);
    expect(thirdCallbackCalled, isTrue);
  });

  test('unregisterOnBrakeSeriesUpdated_whenCalled_isNotInvokedAnymore', () {
    // ARRANGE
    final aBrakeSeries = BrakeSeries(trainSeries: TrainSeries.A, brakeSeries: 100);
    void laterCallback() {
      onBrakeSeriesUpdatedCalled = !onBrakeSeriesUpdatedCalled;
    }

    testee.registerOnBrakeSeriesUpdated(laterCallback);
    testee.updateBrakeSeries(aBrakeSeries);
    processStreams();
    expect(onBrakeSeriesUpdatedCalled, isTrue);

    // ACT
    testee.unregisterOnBrakeSeriesUpdated(laterCallback);
    testee.updateBrakeSeries(aBrakeSeries);
    processStreams();

    // EXPECT
    expect(onBrakeSeriesUpdatedCalled, isTrue);
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
    expect(onBrakeSeriesUpdatedCalled, isFalse);
  });

  test('dispose_whenCalled_cancelsSubscription', () {
    // ACT
    testee.dispose();
    processStreams();

    // EXPECT
    expect(rxMockJourney.hasListener, isFalse);
  });
}
