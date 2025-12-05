import 'dart:collection';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/illegal_speed_segment.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/replacement_series_model.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'replacement_series_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
  MockSpec<JourneyPositionViewModel>(),
])
void main() {
  late ReplacementSeriesViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
  late BehaviorSubject<JourneySettings> journeySettingsSubject;

  final journey = Journey(
    metadata: Metadata(
      availableBreakSeries: {
        BreakSeries(trainSeries: .N, breakSeries: 180),
        BreakSeries(trainSeries: .N, breakSeries: 160),
        BreakSeries(trainSeries: .R, breakSeries: 120),
        BreakSeries(trainSeries: .A, breakSeries: 100),
        BreakSeries(trainSeries: .D, breakSeries: 100),
      },
      breakSeries: BreakSeries(trainSeries: .N, breakSeries: 180),
      lineSpeeds: SplayTreeMap.from({
        0: [
          TrainSeriesSpeed(
            trainSeries: .N,
            breakSeries: 180,
            speed: SingleSpeed(value: '120'),
          ),
          TrainSeriesSpeed(
            trainSeries: .N,
            breakSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
          TrainSeriesSpeed(
            trainSeries: .R,
            breakSeries: 120,
            speed: SingleSpeed(value: '105'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.A,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        1: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 180,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 160,
            speed: SingleSpeed(value: 'XX'),
          ),
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
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        2: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 180,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
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
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
        3: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 180,
            speed: SingleSpeed(value: '120'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            breakSeries: 160,
            speed: SingleSpeed(value: '110'),
          ),
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
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            breakSeries: 100,
            speed: SingleSpeed(value: '100'),
          ),
        ],
      }),
    ),
    data: [
      ServicePoint(name: 'A', abbreviation: '', order: 0, kilometre: []),
      ServicePoint(name: 'B', abbreviation: '', order: 1, kilometre: []),
      ServicePoint(name: 'C', abbreviation: '', order: 2, kilometre: []),
      ServicePoint(name: 'D', abbreviation: '', order: 3, kilometre: []),
      ServicePoint(name: 'E', abbreviation: '', order: 4, kilometre: []),
      CurvePoint(
        order: 5,
        kilometre: [],
        localSpeeds: [
          TrainSeriesSpeed(
            trainSeries: TrainSeries.N,
            speed: SingleSpeed(value: 'XX'),
          ),
          TrainSeriesSpeed(
            trainSeries: TrainSeries.D,
            speed: SingleSpeed(value: 'XX'),
          ),
        ],
      ),
      ServicePoint(name: 'F', abbreviation: '', order: 6, kilometre: []),
    ],
  );

  setUp(() {
    mockJourneyPositionViewModel = MockJourneyPositionViewModel();
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
    journeySettingsSubject = BehaviorSubject<JourneySettings>.seeded(JourneySettings());
    when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockJourneyPositionViewModel.model).thenAnswer((_) => journeyPositionSubject.stream);
    when(mockJourneyPositionViewModel.modelValue).thenAnswer((_) => journeyPositionSubject.value);
    when(mockJourneyTableViewModel.settings).thenAnswer((_) => journeySettingsSubject.stream);
    when(mockJourneyTableViewModel.settingsValue).thenAnswer((_) => journeySettingsSubject.value);

    testee = ReplacementSeriesViewModel(
      journeyTableViewModel: mockJourneyTableViewModel,
      journeyPositionViewModel: mockJourneyPositionViewModel,
    );
  });

  test('test provides correct replacement series', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test provides correct replacement series, selects series, returns orignal on end', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
        ReplacementSeriesSelected(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
        OriginalSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
      ),
    );

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[2] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[3] as JourneyPoint),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
      ),
    );

    testee.dispose();
  });

  test('test does not emit replacement, when none is found', () async {
    expectLater(
      testee.model,
      emitsInOrder([null]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.D, breakSeries: 100),
      ),
    );

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test recalculates when switching to not suggested breakSeries', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[2] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 160),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );
    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 160),
      ),
    );

    testee.dispose();
  });

  test('test notification disappears after reaching end of segment without user interaction', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[1] as ServicePoint,
            end: journey.data[3] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[1] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[2] as JourneyPoint),
    );
    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[3] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test provides replacement series on invalid localSpeed', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        ReplacementSeriesAvailable(
          segment: IllegalSpeedSegment(
            start: journey.data[4] as ServicePoint,
            end: journey.data[6] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.N, breakSeries: 180),
            replacement: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
          ),
        ),
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeyPositionSubject,
      JourneyPositionModel(currentPosition: journey.data[4] as JourneyPoint),
    );

    testee.dispose();
  });

  test('test emits no replacement when there is a illegal segment without replacement available', () async {
    expectLater(
      testee.model,
      emitsInOrder([
        null,
        NoReplacementSeries(
          segment: IllegalSpeedSegment(
            start: journey.data[4] as ServicePoint,
            end: journey.data[6] as ServicePoint,
            original: BreakSeries(trainSeries: TrainSeries.D, breakSeries: 100),
            replacement: null,
          ),
        ),
        null,
      ]),
    );

    journeySubject.add(journey);

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.D, breakSeries: 100),
      ),
    );

    await emitObjectToStream(
      journeySettingsSubject,
      JourneySettings(
        selectedBreakSeries: BreakSeries(trainSeries: TrainSeries.R, breakSeries: 120),
      ),
    );

    testee.dispose();
  });
}

Future<void> emitObjectToStream<T>(BehaviorSubject<T> subject, T object) async {
  subject.add(object);
  await Future.delayed(const Duration(milliseconds: 10));
}
