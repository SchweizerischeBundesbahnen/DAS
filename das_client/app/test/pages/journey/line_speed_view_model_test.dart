import 'dart:collection';

import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'line_speed_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  late LineSpeedViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  var journeySettings = JourneySettings();

  final journey = Journey(
    metadata: Metadata(
      availableBreakSeries: {
        BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
        BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100),
      },
      breakSeries: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
      lineSpeeds: SplayTreeMap.from({
        0: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            breakSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        5: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            breakSeries: 120,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        10: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.R,
            breakSeries: 120,
            speed: SingleSpeed(value: '95'),
          ),
        ],
      }),
    ),
    data: [
      ServicePoint(name: 'A', abbreviation: '', order: 0, kilometre: []),
      ServicePoint(name: 'B', abbreviation: '', order: 5, kilometre: []),
      ServicePoint(name: 'C', abbreviation: '', order: 10, kilometre: []),
      ServicePoint(name: 'D', abbreviation: '', order: 15, kilometre: []),
      ServicePoint(name: 'E', abbreviation: '', order: 20, kilometre: []),
      ServicePoint(name: 'F', abbreviation: '', order: 30, kilometre: []),
    ],
  );

  setUp(() {
    journeySettings = JourneySettings();
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    journeySubject = BehaviorSubject<Journey?>();
    journeySubject.add(journey);
    when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockJourneyTableViewModel.settingsValue).thenAnswer((_) => journeySettings);

    testee = LineSpeedViewModel(journeyTableViewModel: mockJourneyTableViewModel);
  });

  tearDown(() {
    journeySubject.close();
    testee.dispose();
  });

  test('test return none when journey is null', () async {
    journeySubject.add(null);
    await processStreams();

    expect(testee.getResolvedSpeedForOrder(0), ResolvedTrainSeriesSpeed.none());
    expect(testee.getResolvedSpeedForOrder(10), ResolvedTrainSeriesSpeed.none());
  });

  test('test resolves speed for default break series', () async {
    expect(
      testee.getResolvedSpeedForOrder(0),
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '105'),
          breakSeries: 120,
        ),
        isPrevious: false,
      ),
    );
    expect(
      testee.getResolvedSpeedForOrder(5),
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '100'),
          breakSeries: 120,
        ),
        isPrevious: false,
      ),
    );
  });

  test('test uses breakSeries from settings', () async {
    journeySettings = JourneySettings(
      selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100),
    );

    expect(
      testee.getResolvedSpeedForOrder(0),
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.A,
          speed: SingleSpeed(value: '100'),
          breakSeries: 100,
        ),
        isPrevious: false,
      ),
    );
  });

  test('test return previous if not defined on exact point', () async {
    expect(
      testee.getResolvedSpeedForOrder(18),
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '95'),
          breakSeries: 120,
        ),
        isPrevious: true,
      ),
    );
  });

  test('test return previous over multiple last entries', () async {
    journeySettings = JourneySettings(
      selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100),
    );

    expect(
      testee.getResolvedSpeedForOrder(18),
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.A,
          speed: SingleSpeed(value: '100'),
          breakSeries: 100,
        ),
        isPrevious: true,
      ),
    );
  });

  test('test return none if not found', () async {
    journeySettings = JourneySettings(
      selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 100),
    );

    expect(
      testee.getResolvedSpeedForOrder(18),
      ResolvedTrainSeriesSpeed.none(),
    );
  });
}

Future<void> processStreams() async => await Future.delayed(Duration.zero);
