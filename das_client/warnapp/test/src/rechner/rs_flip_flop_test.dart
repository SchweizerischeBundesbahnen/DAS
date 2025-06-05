import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/rs_flip_flop.dart';

void main() {
  group('RSFlipFlop Tests', () {
    test('Null Size Set', () {
      final flipflop = RSFlipFlop(0, 1);
      expect(() => flipflop.set([true], [], [true]), throwsException);
    });

    test('Null Size Reset', () {
      final flipflop = RSFlipFlop(1, 0);
      expect(() => flipflop.set([true], [], [true]), throwsException);
    });

    test('Wrong Size Set', () {
      final flipflop = RSFlipFlop(3, 0);
      final array = [false, true, false, true, false, true];
      expect(() => flipflop.set(array, [], []), throwsException);
    });

    test('Wrong Size Reset', () {
      final flipflop = RSFlipFlop(0, 6);
      final array = [false, true, false, true, false];
      expect(() => flipflop.set([], [], array), throwsException);
    });

    test('Single Value', () {
      final flipflop = RSFlipFlop(1, 1);

      expect(flipflop.state, isFalse);
      flipflop.set([false], [], [false]);
      expect(flipflop.state, isFalse);

      flipflop.set([true], [], [false]);
      flipflop.set([false], [], [false]);

      expect(flipflop.state, isTrue);

      flipflop.set([true], [], [false]);
      flipflop.set([false], [], [false]);

      expect(flipflop.state, isTrue);

      flipflop.set([false], [], [true]);
      flipflop.set([false], [], [false]);

      expect(flipflop.state, isFalse);

      flipflop.set([false], [], [true]);
      flipflop.set([false], [], [false]);

      expect(flipflop.state, isFalse);
    });

    test('Positive Schwelle Erkannt', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([false], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([true], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isTrue);
      flipflop.set([true], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
    });

    test('Negative Schwelle Erkannt', () {
      final flipflop = RSFlipFlop(1, 1);
      flipflop.state = true;

      flipflop.set([false], [], [false]);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      flipflop.set([false], [], [true]);
      expect(flipflop.negativeSchwelleErkannt, isTrue);
      flipflop.set([false], [], [true]);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      flipflop.set([false], [], [false]);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
    });

    test('Ufe Abe', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([false], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);

      flipflop.set([true], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isTrue);
      expect(flipflop.negativeSchwelleErkannt, isFalse);

      flipflop.set([true], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);

      flipflop.set([false], [], [true]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isTrue);

      flipflop.set([false], [], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
    });

    test('Multi Value', () {
      final flipflop = RSFlipFlop(2, 3);

      expect(flipflop.state, isFalse);
      flipflop.set([false, false], [], [false, false, false]);
      expect(flipflop.state, isFalse);

      flipflop.set([false, true], [], [false, false, false]);
      expect(flipflop.state, isTrue);

      flipflop.set([false, false], [], [false, true, false]);
      expect(flipflop.state, isFalse);
    });

    test('Softset alles NO', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([false], [false], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isFalse);
    });

    test('Softset nur Set', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([true], [false], [false]);
      expect(flipflop.positiveSchwelleErkannt, isTrue);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('Softset set und SoftSet', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([true], [true], [false]);
      expect(flipflop.positiveSchwelleErkannt, isTrue);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('Softset nur SoftSet', () {
      final flipflop = RSFlipFlop(1, 1);

      flipflop.set([false], [true], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isTrue);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);

      flipflop.set([false], [false], [false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('MultiValue SoftSet', () {
      final flipflop = RSFlipFlop(2, 3);

      expect(flipflop.state, isFalse);
      flipflop.set([false, false], [false], [false, false, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isFalse);

      flipflop.set([false, true], [false], [false, false, false]);
      expect(flipflop.positiveSchwelleErkannt, isTrue);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);

      flipflop.set([false, true], [false], [false, true, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isTrue);
      expect(flipflop.state, isFalse);

      flipflop.set([false, false], [true], [false, false, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isTrue);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('MultiValue reset übersteuert set', () {
      final flipflop = RSFlipFlop(2, 3);

      expect(flipflop.state, isFalse);
      flipflop.set([true, false], [false], [false, true, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isFalse);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isFalse);
    });

    test('MultiValue softset übersteuert reset', () {
      final flipflop = RSFlipFlop(2, 3);

      expect(flipflop.state, isFalse);
      flipflop.set([false, false], [true], [false, true, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isTrue);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('MultiValue reset wenn softset setzt negative Flanke nicht', () {
      final flipflop = RSFlipFlop(2, 3);

      flipflop.set([true, false], [false], [false, false, false]);
      expect(flipflop.state, isTrue);
      flipflop.set([false, false], [true], [false, true, false]);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      expect(flipflop.softSetErkannt, isTrue);
      expect(flipflop.negativeSchwelleErkannt, isFalse);
      expect(flipflop.state, isTrue);
    });

    test('MultiValue softSetDauernGesetzt', () {
      final flipflop = RSFlipFlop(1, 1);

      expect(flipflop.state, isFalse);
      flipflop.set([false], [false], [false]);
      expect(flipflop.state, isFalse);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [true]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([true], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
      flipflop.set([false], [true], [false]);
      expect(flipflop.state, isTrue);
      expect(flipflop.positiveSchwelleErkannt, isFalse);
    });

    void withFlipFlop(
      RSFlipFlop flipflop,
      List<bool> valuesSet,
      List<bool>? valuesSoftSet,
      List<bool> valuesReset,
      void Function() assert1,
      void Function() assert2, [
      void Function()? assert3,
    ]) {
      flipflop.set(valuesSet, valuesSoftSet ?? [], valuesReset);
      assert1();
      assert2();
      if (assert3 != null) {
        assert3();
      }
    }

    test('positiveSchwelleErkannt should return true when minimaleAnzahlZwischenZweiSets is 0', () {
      final flipflop = RSFlipFlop(1, 1);
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isTrue),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [true],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );

      // Hier wird eine positive Schwelle erkannt, da minimaleAnzahlZwischenZweiSets bereits erreicht
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isTrue),
      );
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
    });

    test('positiveSchwelleErkannt should return true after minimaleAnzahlZwischenZweiSets', () {
      final flipflop = RSFlipFlop(1, 1, 5);
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isTrue),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [true],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );

      // Hier wird eine positive Schwelle erkannt, da minimaleAnzahlZwischenZweiSets bereits erreicht
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isTrue),
      );
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
    });

    test('positiveSchwelleErkannt should return false before minimaleAnzahlZwischenZweiSets', () {
      final flipflop = RSFlipFlop(1, 1, 10);

      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isTrue),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [true],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [false],
        null,
        [false],
        () => expect(flipflop.state, isFalse),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );

      // Hier wird keine positive Schwelle erkannt, da minimaleAnzahlZwischenZweiSets noch nicht erreicht
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
      withFlipFlop(
        flipflop,
        [true],
        null,
        [false],
        () => expect(flipflop.state, isTrue),
        () => expect(flipflop.positiveSchwelleErkannt, isFalse),
      );
    });
  });
}
