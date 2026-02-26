import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/view_mode_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewModeViewModel', () {
    late ViewModeViewModel testee;
    late List<dynamic> emitRegister;
    late StreamSubscription sub;

    setUp(() {
      testee = ViewModeViewModel();
      emitRegister = <dynamic>[];
      sub = testee.isZenViewMode.listen(emitRegister.add);
    });

    tearDown(() {
      sub.cancel();
      testee.dispose();
    });

    test('initialState_whenInstantiated_thenIsTrue', () {
      // EXPECT
      expect(testee.isZenViewModeValue, isTrue);
    });

    test('isZenViewMode_whenInstantiated_thenEmitsTrue', () {
      // EXPECT
      expect(emitRegister.first, isTrue);
    });

    test('updateZenViewMode_whenCalledWithPausedState_thenSetsFalse', () {
      // ARRANGE
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());

      // ACT
      testee.updateZenViewMode(pausedState);

      // EXPECT
      expect(testee.isZenViewModeValue, isFalse);
      expect(emitRegister.last, isFalse);
    });

    test('updateZenViewMode_whenCalledWithAutomaticState_thenSetsTrue', () {
      // ARRANGE
      emitRegister.clear();
      final automaticState = Automatic();

      // ACT
      testee.updateZenViewMode(automaticState);

      // EXPECT
      expect(testee.isZenViewModeValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('updateZenViewMode_whenCalledWithManualState_thenSetsTrue', () {
      // ARRANGE
      emitRegister.clear();
      final manualState = Manual();

      // ACT
      testee.updateZenViewMode(manualState);

      // EXPECT
      expect(testee.isZenViewModeValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('updateZenViewMode_whenCalledMultipleTimes_thenEmitsForEachUpdate', () {
      // ARRANGE
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());
      final automaticState = Automatic();

      // ACT
      testee.updateZenViewMode(pausedState);
      testee.updateZenViewMode(automaticState);
      testee.updateZenViewMode(pausedState);

      // EXPECT
      expect(emitRegister.length, 3);
      expect(emitRegister[0], isFalse);
      expect(emitRegister[1], isTrue);
      expect(emitRegister[2], isFalse);
    });

    test('updateZenViewMode_whenCalledWithSameStateTwice_thenStillEmits', () {
      // ARRANGE
      emitRegister.clear();
      final pausedState = Paused(next: Automatic());

      // ACT
      testee.updateZenViewMode(pausedState);
      testee.updateZenViewMode(pausedState);

      // EXPECT
      expect(emitRegister.length, 2);
      expect(emitRegister[0], isFalse);
      expect(emitRegister[1], isFalse);
    });

    test('dispose_whenCalled_thenClosesStream', () {
      // ACT
      testee.dispose();

      // EXPECT
      expect(() => testee.isZenViewModeValue, returnsNormally);
    });

    test('isZenViewMode_afterDispose_thenCannotListen', () async {
      // ARRANGE
      final newSub = testee.isZenViewMode.listen((_) {});
      testee.dispose();

      // ACT & EXPECT
      expect(() => newSub.cancel(), returnsNormally);
    });
  });
}
