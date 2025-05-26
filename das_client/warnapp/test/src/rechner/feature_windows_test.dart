import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/src/rechner/feature_windows.dart';

void main() {
  const double accuracy = 0.001;

  group('FeatureWindows Tests', () {
    test('init', () {
      final windows = FeatureWindows([3, 2, 3]);

      expect(windows.meanDiff(0, 1), closeTo(0, accuracy));
      expect(windows.meanDiff(0, 2), closeTo(0, accuracy));
      expect(windows.meanDiff(1, 2), closeTo(0, accuracy));

      expect(windows.minDiff(0, 1), closeTo(0, accuracy));
      expect(windows.minDiff(0, 2), closeTo(0, accuracy));
      expect(windows.minDiff(1, 2), closeTo(0, accuracy));

      expect(windows.maxDiff(0, 1), closeTo(0, accuracy));
      expect(windows.maxDiff(0, 2), closeTo(0, accuracy));
      expect(windows.maxDiff(1, 2), closeTo(0, accuracy));

      expect(windows.innerDiff(0, 1), closeTo(0, accuracy));
      expect(windows.innerDiff(0, 2), closeTo(0, accuracy));
      expect(windows.innerDiff(1, 2), closeTo(0, accuracy));

      expect(windows.sumDiff(0, 1), closeTo(0, accuracy));
      expect(windows.sumDiff(0, 2), closeTo(0, accuracy));
      expect(windows.sumDiff(1, 2), closeTo(0, accuracy));
    });

    test('multiple updates', () {
      final windows = FeatureWindows([3, 2, 3]);

      windows.update(1); // --> [ 0 0 0] [0 0] [0 0 1]
      windows.update(2); // --> [ 0 0 0] [0 0] [0 1 2]
      windows.update(3); // --> [ 0 0 0] [0 0] [1 2 3]
      windows.update(4); // --> [ 0 0 0] [0 1] [2 3 4]
      windows.update(5); // --> [ 0 0 0] [1 2] [3 4 5]
      windows.update(6); // --> [ 0 0 1] [2 3] [4 5 6]
      windows.update(7); // --> [ 0 1 2] [3 4] [5 6 7]
      windows.update(3); // --> [ 1 2 3] [4 5] [6 7 3]
      windows.update(2); // --> [ 2 3 4] [5 6] [7 3 2]

      expect(windows.mean(0), closeTo(3.0, accuracy));
      expect(windows.mean(1), closeTo(5.5, accuracy));
      expect(windows.mean(2), closeTo(4.0, accuracy));
      expect(windows.meanDiff(0, 1), closeTo(-2.5, accuracy));
      expect(windows.meanDiff(0, 2), closeTo(-1.0, accuracy));
      expect(windows.meanDiff(1, 2), closeTo(1.5, accuracy));

      expect(windows.min(0), closeTo(2, accuracy));
      expect(windows.min(1), closeTo(5, accuracy));
      expect(windows.min(2), closeTo(2, accuracy));
      expect(windows.minDiff(0, 1), closeTo(-3, accuracy));
      expect(windows.minDiff(0, 2), closeTo(0, accuracy));
      expect(windows.minDiff(1, 2), closeTo(3, accuracy));

      expect(windows.max(0), closeTo(4, accuracy));
      expect(windows.max(1), closeTo(6, accuracy));
      expect(windows.max(2), closeTo(7, accuracy));
      expect(windows.maxDiff(0, 1), closeTo(-2, accuracy));
      expect(windows.maxDiff(0, 2), closeTo(-3, accuracy));
      expect(windows.maxDiff(1, 2), closeTo(-1, accuracy));

      // inner0 (2*2 + 3*3 + 4*4) / 3 = 29 / 3 = 9.6666
      // inner1 (5*5 + 6*6) / 2 = 61 / 2 = 30.5
      // inner2 (7*7 + 3*3 + 2*2) / 3 = 62 / 3 = 20.6666
      expect(windows.inner(0), closeTo(9.666, accuracy));
      expect(windows.inner(1), closeTo(30.5, accuracy));
      expect(windows.inner(2), closeTo(20.666, accuracy));
      expect(windows.innerDiff(0, 1), closeTo(-20.8333, accuracy));
      expect(windows.innerDiff(0, 2), closeTo(-11, accuracy));
      expect(windows.innerDiff(1, 2), closeTo(9.83333, accuracy));

      expect(windows.sum(0), closeTo(9, accuracy));
      expect(windows.sum(1), closeTo(11, accuracy));
      expect(windows.sum(2), closeTo(12, accuracy));
      expect(windows.sumDiff(0, 1), closeTo(-2, accuracy));
      expect(windows.sumDiff(0, 2), closeTo(-3, accuracy));
      expect(windows.sumDiff(1, 2), closeTo(-1, accuracy));
    });
  });
}
