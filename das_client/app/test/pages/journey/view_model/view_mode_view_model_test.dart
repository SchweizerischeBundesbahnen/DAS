import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/view_mode_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import '../../../test_util.dart';
import 'view_mode_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  group('ViewModeViewModel', () {
    late ViewModeViewModel testee;
    late List<dynamic> emitRegister;
    late StreamSubscription sub;
    late MockJourneyViewModel mockJourneyViewModel;

    setUp(() {
      mockJourneyViewModel = MockJourneyViewModel();
      testee = ViewModeViewModel(
        journeySettingsViewModel: JourneySettingsViewModel(journeyViewModel: mockJourneyViewModel),
      );
      emitRegister = <dynamic>[];
      sub = testee.isZenViewMode.listen(emitRegister.add);
    });

    tearDown(() {
      sub.cancel();
      testee.dispose();
    });

    test('initialState_whenInstantiated_thenIsTrue', () {
      // THEN
      expect(testee.isZenViewModeValue, isTrue);
    });

    test('isZenViewMode_whenInstantiated_thenEmitsTrue', () {
      // THEN
      expect(emitRegister.first, isTrue);
    });

    test('updateZenViewMode_whenCalledWithPausedState_thenSetsFalse', () async {
      // GIVEN
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());

      // WHEN
      testee.updateZenViewMode(pausedState);
      await processStreams();

      // THEN
      expect(testee.isZenViewModeValue, isFalse);
      expect(emitRegister.last, isFalse);
    });

    test('updateZenViewMode_whenCalledWithAutomaticState_thenSetsTrue', () async {
      // GIVEN
      final automaticState = Automatic();

      // WHEN
      testee.updateZenViewMode(automaticState);
      await processStreams();

      // THEN
      expect(testee.isZenViewModeValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('updateZenViewMode_whenCalledWithManualState_thenSetsTrue', () async {
      // GIVEN
      final manualState = Manual();

      // WHEN
      testee.updateZenViewMode(manualState);
      await processStreams();

      // THEN
      expect(testee.isZenViewModeValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('updateZenViewMode_whenCalledMultipleTimes_thenEmitsForEachUpdate', () async {
      // GIVEN
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());
      final automaticState = Automatic();

      // WHEN
      testee.updateZenViewMode(pausedState);
      await processStreams();
      testee.updateZenViewMode(automaticState);
      await processStreams();
      testee.updateZenViewMode(pausedState);
      await processStreams();

      // THEN
      expect(emitRegister.length, 3);
      expect(emitRegister[0], isFalse);
      expect(emitRegister[1], isTrue);
      expect(emitRegister[2], isFalse);
    });

    test('updateZenViewMode_whenCalledWithSameStateTwice_thenOnlyEmitsOnce', () async {
      // GIVEN
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());

      // WHEN
      testee.updateZenViewMode(pausedState);
      await processStreams();
      testee.updateZenViewMode(pausedState);
      await processStreams();

      // THEN
      expect(emitRegister.length, 1);
      expect(emitRegister[0], isFalse);
    });
  });
}
