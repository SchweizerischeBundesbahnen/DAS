import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../test_util.dart';

void main() {
  late DecisiveGradientViewModel testee;

  setUp(() {
    GetIt.I.registerSingleton(TimeConstants());
    testee = DecisiveGradientViewModel();
  });

  tearDown(() {
    testee.dispose();
    GetIt.I.reset();
  });

  test('showDecisiveGradientValue_whenInitialized_thenReturnsFalse', () {
    expect(testee.showDecisiveGradientValue, isFalse);
  });

  test('showDecisiveGradient_whenInitialized_thenEmitsFalse', () async {
    expect(await testee.showDecisiveGradient.first, isFalse);
  });

  test('toggleShowDecisiveGradient_whenToggledOn_thenEmitsTrue', () {
    testee.toggleShowDecisiveGradient();
    expect(testee.showDecisiveGradientValue, isTrue);
  });

  test('toggleShowDecisiveGradient_whenToggledOn_thenStartsTimerToSwitchBack', () {
    FakeAsync().run((fakeAsync) {
      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isTrue);

      fakeAsync.elapse(Duration(seconds: 11));

      expect(testee.showDecisiveGradientValue, isFalse);
    });
  });

  test('toggleShowDecisiveGradient_whenToggledOnThenOff_thenCancelsTimer', () {
    FakeAsync().run((fakeAsync) {
      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isTrue);

      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isFalse);

      fakeAsync.elapse(Duration(seconds: 11));

      expect(testee.showDecisiveGradientValue, isFalse); // Should remain false
    });
  });

  test('toggleShowDecisiveGradient_whenToggledMultipleTimes_thenResetsTimer', () {
    FakeAsync().run((fakeAsync) {
      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isTrue);

      fakeAsync.elapse(Duration(seconds: 5));
      expect(testee.showDecisiveGradientValue, isTrue);

      // Toggle off and on again
      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isFalse);

      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isTrue);

      // Timer should be reset, so after 5 seconds should still be true
      fakeAsync.elapse(Duration(seconds: 5));
      expect(testee.showDecisiveGradientValue, isTrue);

      // After full duration should be false
      fakeAsync.elapse(Duration(seconds: 6));
      expect(testee.showDecisiveGradientValue, isFalse);
    });
  });

  test('showDecisiveGradient_whenToggled_thenEmitsDistinctValues', () async {
    final emittedValues = <bool>[];
    final subscription = testee.showDecisiveGradient.listen(emittedValues.add);

    testee.toggleShowDecisiveGradient();
    await processStreams();

    testee.toggleShowDecisiveGradient();
    await processStreams();

    expect(emittedValues, equals([false, true, false]));

    await subscription.cancel();
  });

  test('dispose_whenCalled_thenCancelsTimerAndClosesSubject', () {
    FakeAsync().run((fakeAsync) {
      testee.toggleShowDecisiveGradient();
      expect(testee.showDecisiveGradientValue, isTrue);

      testee.dispose();

      fakeAsync.elapse(Duration(seconds: 11));

      // Timer should not fire after dispose
      expect(testee.showDecisiveGradientValue, isTrue);
    });
  });
}
