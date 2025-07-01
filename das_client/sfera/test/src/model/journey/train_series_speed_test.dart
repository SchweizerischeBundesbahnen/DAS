import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/train_series.dart';
import 'package:sfera/src/model/journey/train_series_speed.dart';

void main() {
  group('Unittest TrainSeriesSpeed', () {
    test('equality_whenEquals_returnsTrue', () {
      final a = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'));
      final b = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'));

      expect(a, equals(b));
    });

    test('equality_whenNotEqual_returnsFalse', () {
      final a = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'));
      final diffTrainSeries = TrainSeriesSpeed(trainSeries: TrainSeries.A, speed: Speed.parse('80'));
      final diffSpeed = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('90'));
      final diffBreakSeries = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'), breakSeries: 100);
      final diffText = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'), text: 'Test');
      final diffReduced = TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80'), reduced: true);

      expect(a == diffTrainSeries, isFalse);
      expect(a == diffSpeed, isFalse);
      expect(a == diffBreakSeries, isFalse);
      expect(a == diffText, isFalse);
      expect(a == diffReduced, isFalse);
    });

    test('toString returns expected format', () {
      final speed = TrainSeriesSpeed(
        trainSeries: TrainSeries.R,
        speed: Speed.parse('80'),
        breakSeries: 100,
        text: 'Test',
        reduced: true,
      );

      expect(speed.toString(), contains('trainSeries: TrainSeries.R'));
      expect(speed.toString(), contains('speed: SingleSpeed'));
      expect(speed.toString(), contains('breakSeries: 100'));
      expect(speed.toString(), contains('text: Test'));
      expect(speed.toString(), contains('reduced: true'));
    });

    test('speedFor_whenNullTrainSeries_returnsNull', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80')),
      ];

      expect(testee.speedFor(null, breakSeries: 150), isNull);
    });

    test('speedFor_whenNoVelocities_returnsNull', () {
      final testee = <TrainSeriesSpeed>[];

      expect(testee.speedFor(TrainSeries.R, breakSeries: 150), isNull);
      expect(testee.speedFor(TrainSeries.A, breakSeries: 150), isNull);
    });

    test('speedFor_whenNoMatchingTrainSeries_returnsNull', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80')),
      ];

      expect(testee.speedFor(TrainSeries.A, breakSeries: 150), isNull);
    });

    test('speedFor_whenExactMatch_returnsCorrectSpeed', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, breakSeries: 100, speed: Speed.parse('100')),
        TrainSeriesSpeed(trainSeries: TrainSeries.R, breakSeries: 150, speed: Speed.parse('150')),
        TrainSeriesSpeed(trainSeries: TrainSeries.A, breakSeries: 100, speed: Speed.parse('200')),
        TrainSeriesSpeed(trainSeries: TrainSeries.A, breakSeries: 150, speed: Speed.parse('250')),
      ];

      final r100 = testee.speedFor(TrainSeries.R, breakSeries: 100);
      expect(r100, isNotNull);
      expect((r100!.speed as SingleSpeed).value, '100');

      final r150 = testee.speedFor(TrainSeries.R, breakSeries: 150);
      expect(r150, isNotNull);
      expect((r150!.speed as SingleSpeed).value, '150');

      final a100 = testee.speedFor(TrainSeries.A, breakSeries: 100);
      expect(a100, isNotNull);
      expect((a100!.speed as SingleSpeed).value, '200');

      final a150 = testee.speedFor(TrainSeries.A, breakSeries: 150);
      expect(a150, isNotNull);
      expect((a150!.speed as SingleSpeed).value, '250');
    });

    test('speedFor_whenNoExactMatchButHasDefault_returnsDefaultSpeed', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, breakSeries: 100, speed: Speed.parse('100')),
        TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('150')),
        TrainSeriesSpeed(trainSeries: TrainSeries.A, speed: Speed.parse('200')),
        TrainSeriesSpeed(trainSeries: TrainSeries.A, breakSeries: 150, speed: Speed.parse('250')),
      ];

      final r50 = testee.speedFor(TrainSeries.R, breakSeries: 50);
      expect(r50, isNotNull);
      expect((r50!.speed as SingleSpeed).value, '150');

      final a100 = testee.speedFor(TrainSeries.A, breakSeries: 100);
      expect(a100, isNotNull);
      expect((a100!.speed as SingleSpeed).value, '200');

      // Exact match
    });

    test('speedFor_whenNoExactMatchAndNoDefault_returnsNull', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, breakSeries: 100, speed: Speed.parse('100')),
        TrainSeriesSpeed(trainSeries: TrainSeries.A, breakSeries: 150, speed: Speed.parse('250')),
      ];

      expect(testee.speedFor(TrainSeries.R, breakSeries: 50), isNull);

      expect(testee.speedFor(TrainSeries.A, breakSeries: 100), isNull);
    });

    test('speedFor_prioritizesExactMatchOverDefault', () {
      final testee = <TrainSeriesSpeed>[
        TrainSeriesSpeed(trainSeries: TrainSeries.R, speed: Speed.parse('80')),
        TrainSeriesSpeed(trainSeries: TrainSeries.R, breakSeries: 100, speed: Speed.parse('100')),
      ];

      final result = testee.speedFor(TrainSeries.R, breakSeries: 100);
      expect(result, isNotNull);
      expect((result!.speed as SingleSpeed).value, '100');
    });
  });
}
