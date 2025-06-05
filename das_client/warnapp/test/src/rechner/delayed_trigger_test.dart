import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/delayed_trigger.dart';

void main() {
  group('WAPDelayedTrigger Tests', () {
    test('Init No Throw', () {
      expect(() => DelayedTrigger(false, 0, 0), returnsNormally);
    });

    test('Init False', () {
      final trigger = DelayedTrigger(false, 0, 0);
      expect(trigger.state, isFalse);
    });

    test('Init True', () {
      final trigger = DelayedTrigger(true, 0, 0);
      expect(trigger.state, isTrue);
    });

    test('Update', () {
      final trigger = DelayedTrigger(false, 3, 0);

      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isFalse);
    });

    test('Flanke Zuruecksetzen Vor Delay', () {
      final trigger = DelayedTrigger(true, 5, 0);

      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
    });

    test('Naechste Positive Flanke Verlaengert Delay', () {
      final trigger = DelayedTrigger(false, 5, 0);

      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- erste positive Flanke
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- dies verlängert den Delay
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- hier würde die erste Flanke zuschlagen
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isTrue); // <- hier muss Flanke zuschlagen
      expect(trigger.updateWithTrigger(true), isTrue);
    });

    test('Naechste Positive Flanke Verlaengert Delay beide Anzahl gesetzt', () {
      final trigger = DelayedTrigger(false, 5, 5);

      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- erste positive Flanke
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(false), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- dies verlängert den Delay
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse); // <- hier würde die erste Flanke zuschlagen
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isFalse);
      expect(trigger.updateWithTrigger(true), isTrue); // <- hier muss Flanke zuschlagen
      expect(trigger.updateWithTrigger(true), isTrue);
    });

    test('Naechste Negative Flanke Verlaengert Delay', () {
      final trigger = DelayedTrigger(true, 0, 5);

      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- erste negative Flanke
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- dies verlängert den Delay
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- hier würde die erste Flanke zuschlagen
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isFalse); // <- hier muss Flanke zuschlagen
      expect(trigger.updateWithTrigger(false), isFalse);
    });

    test('Naechste Negative Flanke Verlaengert Delay beide Anzahl gesetzt', () {
      final trigger = DelayedTrigger(true, 5, 5);

      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- erste negative Flanke
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- dies verlängert den Delay
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue); // <- hier würde die erste Flanke zuschlagen
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isFalse); // <- hier muss Flanke zuschlagen
      expect(trigger.updateWithTrigger(false), isFalse);
    });

    test('Negative Flanke Zuruecksetzen Vor Delay', () {
      final trigger = DelayedTrigger(true, 0, 5);

      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(false), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
      expect(trigger.updateWithTrigger(true), isTrue);
    });

    test('Schwelle', () {
      final trigger = DelayedTrigger(false, 3, 0);

      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, true, true, true, false);
      update(trigger, true, true, false, false);
      update(trigger, false, false, false, true);
      update(trigger, false, false, false, false);
    });

    test('Schwelle Zuruecksetzen Vor Delay', () {
      final trigger = DelayedTrigger(false, 5, 0);

      update(trigger, false, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, true, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
      update(trigger, false, false, false, false);
    });

    test('Zero Delay', () {
      final trigger = DelayedTrigger(false, 0, 0);

      update(trigger, false, false, false, false);
      update(trigger, true, true, true, false);
      update(trigger, false, false, false, true);
      update(trigger, true, true, true, false);
      update(trigger, true, true, false, false);
      update(trigger, false, false, false, true);
      update(trigger, false, false, false, false);
      update(trigger, true, true, true, false);
    });
  });
}

void update(
  DelayedTrigger trigger,
  bool value,
  bool state,
  bool positiveSchwelleErkannt,
  bool negativeSchwelleErkannt,
) {
  expect(trigger.updateWithTrigger(value), equals(state));
  expect(trigger.state, equals(state));
  expect(trigger.positiveSchwelleErkannt, equals(positiveSchwelleErkannt));
  expect(trigger.negativeSchwelleErkannt, equals(negativeSchwelleErkannt));
}
