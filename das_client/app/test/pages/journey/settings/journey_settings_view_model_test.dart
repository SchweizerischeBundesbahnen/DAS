import 'dart:async';

import 'package:app/pages/journey/settings/journey_settings.dart';
import 'package:app/pages/journey/settings/journey_settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';

void main() {
  late JourneySettingsViewModel testee;
  late BehaviorSubject<Journey?> rxMockJourney;
  late StreamSubscription<JourneySettings> modelSubscription;
  late List<dynamic> emitRegister;
  bool onBreakSeriesUpdatedCalled = false;
  void onBreakSeriesUpdatedCallback() {
    onBreakSeriesUpdatedCalled = true;
  }

  setUp(() {
    onBreakSeriesUpdatedCalled = false;
    rxMockJourney = BehaviorSubject<Journey?>.seeded(null);

    testee = JourneySettingsViewModel(
      journeyStream: rxMockJourney.stream,
      onBreakSeriesUpdated: onBreakSeriesUpdatedCallback,
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

  test('onBreakSeriesChanged_whenCalled_emitsCorrectBreakSeriesAndCallsCallback', () {
    // ARRANGE
    final aBreakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100);
    expect(onBreakSeriesUpdatedCalled, isFalse);
    // ACT
    testee.onBreakSeriesChanged(aBreakSeries);
    processStreams();
    // EXPECT
    expect(testee.modelValue, equals(JourneySettings(selectedBreakSeries: aBreakSeries)));
    expect(emitRegister, hasLength(1));
    expect(onBreakSeriesUpdatedCalled, isTrue);
  });

  test('onExpandedGroupsChanged_whenCalled_emitsCorrectExpandedGroups', () {
    // ARRANGE
    final aExpandedGroups = const [1, 2];

    // ACT
    testee.onExpandedGroupsChanged(aExpandedGroups);
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
