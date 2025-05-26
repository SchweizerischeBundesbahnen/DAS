import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/location_fahrt_hysterese.dart';

void main() {
  group('LocationFahrtHysterese Tests', () {
    test('Init Length 5 And 3', () {
      final hysterese = LocationFahrtHysterese(5, 3);

      expect(hysterese.fahrt, isFalse);
      expect(hysterese.gueltigkeitsDauer, equals(3));
      expect(hysterese.schwelleSpeed, equals(5));
    });

    test('Sequenz', () {
      final hysterese = LocationFahrtHysterese(5, 3);

      expect(hysterese.updateWithSpeed(0, 1), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(5.1, 1), isTrue); // --> geht auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isFalse); // --> geht auf FALSE: Gueltigkeitsdauer abgelaufen
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
    });

    test('NegativSpeed', () {
      final hysterese = LocationFahrtHysterese(5, 3);

      expect(hysterese.updateWithSpeed(5.1, 1), isTrue);
      expect(hysterese.updateWithSpeed(-1, 1), isFalse); // --> geht auf FALSE
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(-1, 1), isFalse); // --> bleibt auf FALSE
    });

    test('updateWithSpeed aufsteigend und absteigend', () {
      final hysterese = LocationFahrtHysterese(3, 3);

      expect(hysterese.updateWithSpeed(0, 1), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(1.0, 1), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(2.0, 1), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(2.8, 1), isFalse);
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(3.1, 1), isTrue); // --> geht auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.8, 1), isTrue); // --> bleibt auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.0, 1), isFalse); // jetzt ist die Gültigkeit abgelaufen
    });

    test('updateWithSpeed waehrend fahrt absteigend', () {
      final hysterese = LocationFahrtHysterese(3, 5);

      expect(hysterese.updateWithSpeed(5.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(4.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(3.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.8, 1), isTrue); // --> bleibt auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.7, 1), isTrue); // --> bleibt auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.0, 1), isFalse); // jetzt ist die Gültigkeit abgelaufen
    });

    test('updateWithSpeed waehrend fahrt absteigend mit negativem wert', () {
      final hysterese = LocationFahrtHysterese(3, 5);

      expect(hysterese.updateWithSpeed(5.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(4.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(-1, 1), isFalse); // --> negativer Wert = keine Fahrt mehr
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(2.8, 1), isFalse); // --> bleibt auf FALSE
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(2.7, 1), isFalse); // --> bleibt auf FALSE
    });

    test('updateWithSpeed waehrend fahrt absteigend mit null wert', () {
      final hysterese = LocationFahrtHysterese(3, 5);

      expect(hysterese.updateWithSpeed(5.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(4.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(0, 1), isTrue); // --> Null = bleibt bei Fahrt
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(2.8, 1), isTrue); // --> bleibt auf TRUE
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isFalse); // jetzt ist die Gültigkeit abgelaufen
    });

    test('updateWithSpeed waehrend fahrt mit negativem wert', () {
      final hysterese = LocationFahrtHysterese(3, 5);

      expect(hysterese.updateWithSpeed(5.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(4.0, 1), isTrue);
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(-1, 1), isFalse); // --> negativer Wert = keine Fahrt mehr
      expect(hysterese.updateWithSpeed(0, 0), isFalse);
      expect(hysterese.updateWithSpeed(3.8, 1), isTrue); // --> wieder auf TRUE, da grösser als Schwelle
      expect(hysterese.updateWithSpeed(0, 0), isTrue);
      expect(hysterese.updateWithSpeed(3.7, 1), isTrue); // --> bleibt auf TRUE
    });
  });
}
