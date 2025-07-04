import 'dart:async';

import 'package:app/pages/journey/train_journey/das_table_speed_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('DASTableSpeedViewModel', () {
    late StreamController<Journey?> journeyController;
    late StreamController<TrainJourneySettings> settingsController;
    late DASTableSpeedViewModel testee;

    setUp(() {
      journeyController = StreamController<Journey?>.broadcast();
      settingsController = StreamController<TrainJourneySettings>.broadcast();
      testee = DASTableSpeedViewModel(
        journeyStream: journeyController.stream,
        settingsStream: settingsController.stream,
      );
    });

    tearDown(() {
      testee.dispose();
      journeyController.close();
      settingsController.close();
    });

    test(
      'previousLineSpeed_whenJourneyIsNull_thenReturnsNull',
      () => expect(testee.previousLineSpeed(0), isNull),
    );

    test('previousLineSpeed_whenSettingsIsNull_thenReturnsNull', () {
      // ARRANGE
      journeyController.add(Journey.invalid());

      // ACT & EXPECT
      expect(testee.previousLineSpeed(0), isNull);
    });

    test(
      'previousCalculatedSpeed_whenJourneyIsNull_thenReturnsNull',
      () => expect(testee.previousCalculatedSpeed(0), isNull),
    );

    group('with journey and settings with speeds', () {
      late Journey journey;
      late TrainJourneySettings settings;
      late TrainSeries trainSeries;
      late BreakSeries breakSeries;
      const lineSpeedRowZero = SingleSpeed(value: '120');
      const lineSpeedRowOne = SingleSpeed(value: '140');
      const lineSpeedRowTwo = SingleSpeed(value: '160');
      const calculatedSpeedRowZero = SingleSpeed(value: '100');
      const calculatedSpeedRowOne = SingleSpeed(value: '120');

      setUp(() {
        trainSeries = TrainSeries.A;
        breakSeries = BreakSeries(trainSeries: TrainSeries.A, breakSeries: 1);

        final metadata = Metadata(breakSeries: breakSeries);

        final data = <BaseData>[
          ServicePoint(
            name: 'Point 1',
            speeds: [
              TrainSeriesSpeed(
                trainSeries: trainSeries,
                speed: lineSpeedRowZero,
                breakSeries: breakSeries.breakSeries,
              ),
            ],
            calculatedSpeed: calculatedSpeedRowZero,
            order: 0,
            kilometre: [],
          ),
          ServicePoint(
            name: 'Point 2',
            speeds: [
              TrainSeriesSpeed(
                trainSeries: trainSeries,
                speed: lineSpeedRowOne,
                breakSeries: breakSeries.breakSeries,
              ),
            ],
            calculatedSpeed: calculatedSpeedRowOne,
            order: 1,
            kilometre: [],
          ),
        ];

        journey = Journey(metadata: metadata, data: data);
        settings = const TrainJourneySettings();

        journeyController.add(journey);
        settingsController.add(settings);
      });

      test('previousLineSpeed_whenRowIndexGiven_returnsCorrectSpeeds', () {
        // ACT & EXPECT for both rows
        expect(testee.previousLineSpeed(1), equals(lineSpeedRowZero));
        expect(testee.previousLineSpeed(2), equals(lineSpeedRowOne));
      });

      test('previousCalculatedSpeed_whenRowIndexGiven_returnsCorrectSpeeds', () {
        // ACT & EXPECT for both rows
        expect(testee.previousCalculatedSpeed(1), equals(calculatedSpeedRowZero));
        expect(testee.previousCalculatedSpeed(2), equals(calculatedSpeedRowOne));
      });

      test('previousLineSpeed_whenDifferentBreakSeriesInSettings_thenReturnsNull', () {
        // ARRANGE
        final newBreakSeries = BreakSeries(trainSeries: trainSeries, breakSeries: 2);
        final newSettings = TrainJourneySettings(selectedBreakSeries: newBreakSeries);
        settingsController.add(newSettings);

        // ACT & EXPECT
        expect(testee.previousLineSpeed(1), isNull);
      });

      test('previousLineSpeed_whenOverarchingRowsWithNullSpeeds_returnsLastNonNullSpeed', () {
        // ARRANGE
        final mixedData = <BaseData>[
          ServicePoint(
            name: 'Point 1',
            speeds: [
              TrainSeriesSpeed(
                trainSeries: trainSeries,
                speed: lineSpeedRowZero,
                breakSeries: breakSeries.breakSeries,
              ),
            ],
            order: 0,
            kilometre: [],
          ),
          ServicePoint(
            name: 'Point 2',
            speeds: [],
            order: 1,
            kilometre: [], // No speeds
          ),
          ServicePoint(
            name: 'Point 3',
            speeds: [
              TrainSeriesSpeed(
                trainSeries: trainSeries,
                speed: lineSpeedRowTwo,
                breakSeries: breakSeries.breakSeries,
              ),
            ],
            order: 2,
            kilometre: [],
          ),
        ];

        journeyController.add(Journey(metadata: journey.metadata, data: mixedData));

        // ACT & EXPECT
        expect(testee.previousLineSpeed(2), equals(lineSpeedRowOne));
        expect(testee.previousLineSpeed(3), equals(lineSpeedRowTwo));
      });
    });

    group('with journey without speeds', () {
      late Journey journey;
      late TrainJourneySettings settings;

      setUp(() {
        final metadata = Metadata();

        final data = <BaseData>[
          ServicePoint(
            name: 'Point 1',
            speeds: [],
            order: 0,
            kilometre: [],
          ),
          ServicePoint(
            name: 'Point 2',
            speeds: [],
            order: 1,
            kilometre: [],
          ),
        ];

        journey = Journey(metadata: metadata, data: data);
        settings = const TrainJourneySettings();

        journeyController.add(journey);
        settingsController.add(settings);
      });

      test('previousLineSpeed_whenNoSpeedsInData_returnsNull', () {
        // ACT & EXPECT
        expect(testee.previousLineSpeed(1), isNull);
        expect(testee.previousLineSpeed(2), isNull);
      });

      test('previousCalculatedSpeed_whenNoCalculatedSpeedsInData_returnsNull', () {
        // ACT & EXPECT
        expect(testee.previousCalculatedSpeed(1), isNull);
        expect(testee.previousCalculatedSpeed(2), isNull);
      });
    });

    test('dispose_whenCalled_cancelsStreamSubscriptions', () {
      expect(() => testee.dispose(), returnsNormally);

      expect(() {
        journeyController.add(Journey.invalid());
        settingsController.add(const TrainJourneySettings());
      }, returnsNormally);
      expect(journeyController.hasListener, isFalse);
      expect(settingsController.hasListener, isFalse);
    });
  });
}
