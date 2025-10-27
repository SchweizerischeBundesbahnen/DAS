import 'dart:collection';

import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'line_speed_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TrainJourneyViewModel>(),
])
void main() {
  late LineSpeedViewModel testee;
  late MockTrainJourneyViewModel mockTrainJourneyViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  TrainJourneySettings trainJourneySettings = TrainJourneySettings();

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
      ServicePoint(name: 'A', order: 0, kilometre: []),
      ServicePoint(name: 'B', order: 5, kilometre: []),
      ServicePoint(name: 'C', order: 10, kilometre: []),
      ServicePoint(name: 'D', order: 15, kilometre: []),
      ServicePoint(name: 'E', order: 20, kilometre: []),
      ServicePoint(name: 'F', order: 30, kilometre: []),
    ],
  );

  setUp(() {
    trainJourneySettings = TrainJourneySettings();
    mockTrainJourneyViewModel = MockTrainJourneyViewModel();
    journeySubject = BehaviorSubject<Journey?>();
    journeySubject.add(journey);
    when(mockTrainJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockTrainJourneyViewModel.settingsValue).thenAnswer((_) => trainJourneySettings);

    testee = LineSpeedViewModel(trainJourneyViewModel: mockTrainJourneyViewModel);
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
    trainJourneySettings = TrainJourneySettings(
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
    trainJourneySettings = TrainJourneySettings(
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
    trainJourneySettings = TrainJourneySettings(
      selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 100),
    );

    expect(
      testee.getResolvedSpeedForOrder(18),
      ResolvedTrainSeriesSpeed.none(),
    );
  });
}

Future<void> processStreams() async => await Future.delayed(Duration.zero);
