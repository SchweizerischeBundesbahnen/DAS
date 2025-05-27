import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/signal_keeper.dart';

void main() {
  const double diff = 0.01;

  group('SignalKeeper Tests', () {
    test('Init Zero', () {
      final keeper = SignalKeeper();
      expect(keeper.updateWithValue(0.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(0.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(0.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(0.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(0.0, 0.0), closeTo(0.0, diff));
    });

    test('Init Freeze', () {
      final keeper = SignalKeeper();
      expect(keeper.updateWithValue(42.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(42.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(42.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(42.0, 0.0), closeTo(0.0, diff));
      expect(keeper.updateWithValue(42.0, 0.0), closeTo(0.0, diff));
    });

    test('Keep', () {
      final keeper = SignalKeeper();

      expect(keeper.updateWithValue(42.0, 1.0), closeTo(42.0, diff));
      expect(keeper.updateWithValue(41.0, 1.0), closeTo(41.0, diff));
      expect(keeper.updateWithValue(40.0, 1.0), closeTo(40.0, diff));

      expect(keeper.updateWithValue(99.0, 0.0), closeTo(40.0, diff));
      expect(keeper.updateWithValue(98.0, 0.0), closeTo(40.0, diff));
      expect(keeper.updateWithValue(97.0, 0.0), closeTo(40.0, diff));
    });

    test('Slow Zero', () {
      final keeper = SignalKeeper();

      expect(keeper.updateWithValue(100.0, 1.0), closeTo(100.0, diff));

      expect(keeper.updateWithValue(0.0, 0.5), closeTo(50.0, diff));
      expect(keeper.updateWithValue(0.0, 0.5), closeTo(25.0, diff));
      expect(keeper.updateWithValue(0.0, 0.5), closeTo(12.5, diff));
      expect(keeper.updateWithValue(0.0, 0.5), closeTo(6.25, diff));
    });
  });
}
