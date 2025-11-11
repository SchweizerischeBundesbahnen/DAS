import 'dart:collection';

import 'package:app/pages/journey/calculated_speed.dart';
import 'package:app/pages/journey/calculated_speed_view_model.dart';
import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'calculated_speed_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
  MockSpec<LineSpeedViewModel>(),
])
void main() {
  late CalculatedSpeedViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late MockLineSpeedViewModel mockLineSpeedViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  ResolvedTrainSeriesSpeed resolvedTrainSeriesSpeed = ResolvedTrainSeriesSpeed.none();

  final journey = Journey(
    metadata: Metadata(
      availableBreakSeries: {
        BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
        BreakSeries(trainSeries: TrainSeries.A, breakSeries: 100),
      },
      breakSeries: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
      calculatedSpeeds: SplayTreeMap.from({
        5: SingleSpeed(value: '100'),
        10: null,
        15: SingleSpeed(value: '90'),
        20: SingleSpeed(value: '90'),
        25: SingleSpeed(value: '100'),
      }),
    ),
    data: [
      ServicePoint(name: 'A', order: 0, kilometre: []),
      ServicePoint(name: 'B', order: 5, kilometre: []),
      ServicePoint(name: 'C', order: 10, kilometre: []),
      ServicePoint(name: 'D', order: 15, kilometre: []),
      ServicePoint(name: 'E', order: 20, kilometre: []),
      ServicePoint(name: 'F', order: 25, kilometre: []),
    ],
  );

  setUp(() {
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    mockLineSpeedViewModel = MockLineSpeedViewModel();
    journeySubject = BehaviorSubject<Journey?>();
    journeySubject.add(journey);
    when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(any)).thenAnswer((_) => resolvedTrainSeriesSpeed);

    testee = CalculatedSpeedViewModel(
      journeyTableViewModel: mockJourneyTableViewModel,
      lineSpeedViewModel: mockLineSpeedViewModel,
    );
  });

  tearDown(() {
    journeySubject.close();
    testee.dispose();
  });

  test('test return none when journey is null', () async {
    journeySubject.add(null);
    await processStreams();

    expect(testee.getCalculatedSpeedForOrder(0), CalculatedSpeed.none());
    expect(testee.getCalculatedSpeedForOrder(10), CalculatedSpeed.none());
  });

  test('test return none when not defined', () async {
    await processStreams();
    expect(testee.getCalculatedSpeedForOrder(0), CalculatedSpeed.none());
  });

  test('test return calculated speed when defined for order', () async {
    await processStreams();
    expect(testee.getCalculatedSpeedForOrder(5), CalculatedSpeed(speed: SingleSpeed(value: '100')));
    expect(testee.getCalculatedSpeedForOrder(10), CalculatedSpeed.none());
    expect(testee.getCalculatedSpeedForOrder(15), CalculatedSpeed(speed: SingleSpeed(value: '90')));
  });

  test('test return previous calculated speed', () async {
    await processStreams();
    expect(testee.getCalculatedSpeedForOrder(8), CalculatedSpeed(speed: SingleSpeed(value: '100'), isPrevious: true));
    expect(testee.getCalculatedSpeedForOrder(12), CalculatedSpeed.none());
    expect(testee.getCalculatedSpeedForOrder(17), CalculatedSpeed(speed: SingleSpeed(value: '90'), isPrevious: true));
  });

  test('test is same as previous', () async {
    await processStreams();
    expect(
      testee.getCalculatedSpeedForOrder(15),
      CalculatedSpeed(speed: SingleSpeed(value: '90'), isSameAsPrevious: false),
    );
    expect(
      testee.getCalculatedSpeedForOrder(20),
      CalculatedSpeed(speed: SingleSpeed(value: '90'), isSameAsPrevious: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(21),
      CalculatedSpeed(speed: SingleSpeed(value: '90'), isSameAsPrevious: true, isPrevious: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(25),
      CalculatedSpeed(speed: SingleSpeed(value: '100'), isSameAsPrevious: false),
    );
  });

  test('test is reduced due to line speed', () async {
    await processStreams();

    resolvedTrainSeriesSpeed = ResolvedTrainSeriesSpeed(
      speed: TrainSeriesSpeed(
        trainSeries: TrainSeries.R,
        speed: SingleSpeed(value: '50'),
        breakSeries: 120,
      ),
      isPrevious: false,
    );

    expect(
      testee.getCalculatedSpeedForOrder(5),
      CalculatedSpeed(speed: SingleSpeed(value: '50'), isReducedDueToLineSpeed: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(10),
      CalculatedSpeed.none(),
    );
    expect(
      testee.getCalculatedSpeedForOrder(20),
      CalculatedSpeed(speed: SingleSpeed(value: '50'), isReducedDueToLineSpeed: true, isSameAsPrevious: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(21),
      CalculatedSpeed(
        speed: SingleSpeed(value: '50'),
        isReducedDueToLineSpeed: true,
        isSameAsPrevious: true,
        isPrevious: true,
      ),
    );
  });

  test('test is same as previous and reduced due to line speed interaction', () async {
    await processStreams();

    reset(mockLineSpeedViewModel);
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(15)).thenReturn(
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '50'),
          breakSeries: 120,
        ),
        isPrevious: false,
      ),
    );
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(20)).thenReturn(
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '60'),
          breakSeries: 120,
        ),
        isPrevious: false,
      ),
    );
    when(mockLineSpeedViewModel.getResolvedSpeedForOrder(25)).thenReturn(
      ResolvedTrainSeriesSpeed(
        speed: TrainSeriesSpeed(
          trainSeries: TrainSeries.R,
          speed: SingleSpeed(value: '60'),
          breakSeries: 120,
        ),
        isPrevious: false,
      ),
    );

    expect(
      testee.getCalculatedSpeedForOrder(15),
      CalculatedSpeed(speed: SingleSpeed(value: '50'), isReducedDueToLineSpeed: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(20),
      CalculatedSpeed(speed: SingleSpeed(value: '60'), isReducedDueToLineSpeed: true),
    );
    expect(
      testee.getCalculatedSpeedForOrder(25),
      CalculatedSpeed(speed: SingleSpeed(value: '60'), isReducedDueToLineSpeed: true, isSameAsPrevious: true),
    );
  });
}

Future<void> processStreams() async => await Future.delayed(Duration.zero);
