import 'dart:async';

import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';
import 'journey_settings_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
])
void main() {
  late JourneySettingsViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late BehaviorSubject<Journey?> rxMockJourney;
  late StreamSubscription<JourneySettings> modelSubscription;
  late List<dynamic> emitRegister;
  bool onBrakeSeriesUpdatedCalled = false;

  setUp(() {
    onBrakeSeriesUpdatedCalled = false;
    mockJourneyViewModel = MockJourneyViewModel();
    rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
    when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);

    testee = JourneySettingsViewModel(
      journeyViewModel: mockJourneyViewModel,
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
