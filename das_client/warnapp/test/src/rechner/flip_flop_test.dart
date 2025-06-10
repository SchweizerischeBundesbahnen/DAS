import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/flip_flop.dart';

void main() {
  group('FlipFlop Tests', () {
    test('Init FALSE', () {
      final flipFlop = FlipFlop(false);
      expect(flipFlop.state, isFalse);
    });

    test('Init TRUE', () {
      final flipFlop = FlipFlop(true);
      expect(flipFlop.state, isTrue);
    });

    test('One Trigger', () {
      initWithState(false, false, false, false, false, false, false);
      initWithState(false, true, false, false, true, true, false);
      initWithState(true, false, false, false, false, false, true);
      initWithState(true, true, false, false, true, false, false);

      initWithState(false, false, true, true, false, false, false);
      initWithState(false, true, true, true, false, false, false);
      initWithState(true, false, true, true, true, false, false);
      initWithState(true, true, true, true, true, false, false);
    });

    test('Multi Trigger', () {
      final flipFlop = FlipFlop(false);

      flipFlopTest(flipFlop, false, false, false, false, false, false);
      flipFlopTest(flipFlop, true, true, true, false, false, false);
      flipFlopTest(flipFlop, true, true, true, false, false, false);
      flipFlopTest(flipFlop, true, false, false, false, false, false);
      flipFlopTest(flipFlop, false, false, false, false, false, false);
      flipFlopTest(flipFlop, false, false, false, false, false, false);
      flipFlopTest(flipFlop, true, false, false, true, true, false);
      flipFlopTest(flipFlop, false, false, false, false, false, true);
    });
  });
}

void initWithState(
  bool initialState,
  bool trigger,
  bool disablePositiv,
  bool disableNegativ,
  bool expectedState,
  bool positiveSchwelleErkannt,
  bool negativeSchwelleErkannt,
) {
  final flipFlop = FlipFlop(initialState);
  expect(
    flipFlop.updateWithTrigger(trigger, disablePositiv: disablePositiv, disableNegativ: disableNegativ),
    equals(expectedState),
  );
  expect(flipFlop.state, equals(expectedState));
  expect(flipFlop.positiveSchwelleErkannt, equals(positiveSchwelleErkannt));
  expect(flipFlop.negativeSchwelleErkannt, equals(negativeSchwelleErkannt));
}

void flipFlopTest(
  FlipFlop flipFlop,
  bool trigger,
  bool disablePositiv,
  bool disableNegativ,
  bool expectedState,
  bool positiveSchwelleErkannt,
  bool negativeSchwelleErkannt,
) {
  expect(
    flipFlop.updateWithTrigger(trigger, disablePositiv: disablePositiv, disableNegativ: disableNegativ),
    equals(expectedState),
  );
  expect(flipFlop.state, equals(expectedState));
  expect(flipFlop.positiveSchwelleErkannt, equals(positiveSchwelleErkannt));
  expect(flipFlop.negativeSchwelleErkannt, equals(negativeSchwelleErkannt));
}
